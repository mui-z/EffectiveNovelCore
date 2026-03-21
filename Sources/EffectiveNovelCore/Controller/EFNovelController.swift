//
// Created by osushi on 2022/09/23.
//

import Combine
import Factory
import Foundation

@MainActor
protocol EFNovelControllerProtocol {
  func validate(raw: String) -> ValidationResult<EFNovelScript, [ValidationError]>
  func load(raw: String) -> ValidationResult<EFNovelScript, [ValidationError]>
  func start(script: EFNovelScript) -> AnyPublisher<DisplayEvent, Never>
  func interrupt()
  func resume()
  func resume(at resumeIndex: Int)
  func pause()
  func showTextUntilWaitTag()

  var index: Int { get }
  var speed: Double { get }
  var state: NovelState { get }
}

// MARK: parameter and public functions

@MainActor
public final class EFNovelController: EFNovelControllerProtocol {

  /// Used for the post-start delay so playback works without a spinning `RunLoop.main` (e.g. CLI tools).
  private static let playbackOutputScheduler = DispatchQueue(label: "dev.effectivenovel.controller.playbackOutput")

  public init() {}

  @Injected(\.validateScriptUseCase)
  private var validateScriptUseCase: ValidateScriptUseCaseProtocol

  private let playbackSession = NovelPlaybackSession()

  private let privateOutputStream = PassthroughSubject<DisplayEvent, Never>()

  private var cancellable: Set<AnyCancellable> = []

  public var index: Int { playbackSession.playbackIndex }

  public var speed: Double { playbackSession.playbackSpeed }

  public var defaultSpeed: Double { playbackSession.playbackDefaultSpeed }

  public var state: NovelState { playbackSession.playbackPhase }

  public func validate(raw: String) -> ValidationResult<EFNovelScript, [ValidationError]> {
    validateScriptUseCase.validate(rawAllString: raw)
  }

  public func load(raw: String) -> ValidationResult<EFNovelScript, [ValidationError]> {
    playbackSession.markPrepareForLoad()
    return validateScriptUseCase.validate(rawAllString: raw)
  }

  public func start(script: EFNovelScript) -> AnyPublisher<DisplayEvent, Never> {
    playbackSession.beginStreaming(script: script) { event in
      self.privateOutputStream.send(event)
    }

    return privateOutputStream
      .delay(for: 0.1, scheduler: Self.playbackOutputScheduler)
      .eraseToAnyPublisher()
  }

  public func interrupt() {
    playbackSession.interrupt()
  }

  public func resume() {
    playbackSession.resume()
  }

  public func resume(at resumeIndex: Int) {
    playbackSession.resume(at: resumeIndex)
  }

  public func pause() {
    playbackSession.pause()
  }

  public func showTextUntilWaitTag() {
    playbackSession.showTextUntilWaitTag { event in
      self.privateOutputStream.send(event)
    }
  }
}
