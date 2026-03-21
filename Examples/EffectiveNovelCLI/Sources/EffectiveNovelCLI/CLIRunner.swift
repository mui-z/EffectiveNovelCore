//
// Terminal demo: Enter advances the same way as tap in EffectiveNovelReader.
//

import Combine
import EffectiveNovelCore
import Foundation

// MARK: - Shared state (thread-safe; Combine sink runs off MainActor)

final class CLIState: @unchecked Sendable {
  private let lock = NSLock()
  private var lastEventStorage: DisplayEvent?
  private var finishedStorage = false

  func applyPlaybackEvent(_ event: DisplayEvent) {
    lock.lock()
    lastEventStorage = event
    if case .end = event {
      finishedStorage = true
    }
    lock.unlock()
  }

  var isFinished: Bool {
    lock.lock()
    defer { lock.unlock() }
    return finishedStorage
  }

  func lastEventSnapshot() -> DisplayEvent? {
    lock.lock()
    defer { lock.unlock() }
    return lastEventStorage
  }
}

// MARK: - stdout

enum CLIOutput {
  static func handle(_ event: DisplayEvent) {
    switch event {
    case .character(let c):
      print(c, terminator: "")
      fflush(stdout)
    case .newline:
      print()
      fflush(stdout)
    case .clear:
      print("\u{001B}[2J\u{001B}[3J\u{001B}[H", terminator: "")
      fflush(stdout)
    default:
      break
    }
  }
}

// MARK: - Combine (must not inherit @MainActor from NovelCLIPorts — see crash: dispatch_assert_queue)

final class CancellableBag: @unchecked Sendable {
  private let lock = NSLock()
  private var cancellables = Set<AnyCancellable>()

  func store(_ c: AnyCancellable) {
    lock.lock()
    cancellables.insert(c)
    lock.unlock()
  }
}

private enum CLISubscribe {
  nonisolated static func attach(
    publisher: AnyPublisher<DisplayEvent, Never>,
    queue: DispatchQueue,
    state: CLIState,
    bag: CancellableBag
  ) {
    let sub = publisher
      .receive(on: queue)
      .sink { event in
        state.applyPlaybackEvent(event)
        CLIOutput.handle(event)
      }
    bag.store(sub)
  }
}

// MARK: - MainActor controller port

@MainActor
final class NovelCLIPorts {
  private let controller = EFNovelController()
  private let cancellableBag = CancellableBag()

  func start(novelQueue: DispatchQueue, state: CLIState, rawScript: String) -> Bool {
    switch controller.load(raw: rawScript) {
    case .invalid(let errors):
      print(errors)
      return false
    case .valid(let script):
      let publisher = controller.start(script: script)
      CLISubscribe.attach(publisher: publisher, queue: novelQueue, state: state, bag: cancellableBag)
      return true
    }
  }

  /// Mirrors ContentViewModel.tapScreen in EffectiveNovelReader.
  func enter(snap: DisplayEvent?) {
    switch snap {
    case .tapWait:
      controller.resume()
    case .tapWaitAndNewline:
      print()
      fflush(stdout)
      controller.resume()
    default:
      controller.showTextUntilWaitTag()
    }
  }
}

// MARK: - Script source

enum ScriptSource {
  /// 1) First CLI argument: path to a UTF-8 file (must exist).
  /// 2) Else `sample.novel` in the current working directory.
  /// 3) Else embedded `NovelSampleScript`.
  static func resolve() -> (raw: String, label: String) {
    let args = CommandLine.arguments.dropFirst()
    if let path = args.first {
      var isDir: ObjCBool = false
      if FileManager.default.fileExists(atPath: path, isDirectory: &isDir), !isDir.boolValue,
        let s = try? String(contentsOfFile: path, encoding: .utf8)
      {
        return (s, path)
      }
      fputs("File not found or unreadable: \(path)\n", stderr)
      exit(1)
    }

    let cwdSample = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      .appendingPathComponent("sample.novel")
      .path
    if FileManager.default.fileExists(atPath: cwdSample),
      let s = try? String(contentsOfFile: cwdSample, encoding: .utf8)
    {
      return (s, cwdSample)
    }

    return (NovelSampleScript.text, "(embedded NovelSampleScript)")
  }
}

// MARK: - Entry

enum EffectiveNovelCLIRunner {
  nonisolated(unsafe) private static var installedPorts: NovelCLIPorts?

  static func run() {
    let (rawScript, label) = ScriptSource.resolve()
    fputs("Script: \(label)\n", stderr)

    let state = CLIState()
    let novelQueue = DispatchQueue(label: "dev.effectivenovel.cli")
    let ready = DispatchSemaphore(value: 0)
    final class StartupResult: @unchecked Sendable {
      var ok = false
    }
    let startup = StartupResult()

    Task { @MainActor in
      let ports = NovelCLIPorts()
      Self.installedPorts = ports
      startup.ok = ports.start(novelQueue: novelQueue, state: state, rawScript: rawScript)
      ready.signal()
    }
    ready.wait()

    guard startup.ok else {
      fputs("Startup failed.\n", stderr)
      exit(1)
    }

    print("\n--- EffectiveNovelCLI (Enter = tap) ---\n", terminator: "")

    let done = DispatchSemaphore(value: 0)
    Thread {
      while true {
        if state.isFinished {
          print("\n--- End ---")
          fflush(stdout)
          done.signal()
          return
        }
        guard readLine() != nil else {
          print("\n--- EOF ---")
          fflush(stdout)
          done.signal()
          return
        }
        let snap = state.lastEventSnapshot()
        Task { @MainActor in
          Self.installedPorts?.enter(snap: snap)
        }
      }
    }.start()

    done.wait()
    Thread.sleep(forTimeInterval: 0.15)
    exit(0)
  }
}
