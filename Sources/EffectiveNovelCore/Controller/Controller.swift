//
// Created by osushi on 2022/09/23.
//

import Foundation
import Combine

enum NovelState {
    case loadWait, prepare, running, pause
}

let defaultSpeed: Double = 250

public class NovelController {

    public init() {
    }

    private var internalOutputStream = PassthroughSubject<DisplayEvent, Never>()

    private var displayEvents: [DisplayEvent] = []

    private var cancellable: Set<AnyCancellable> = []

    private(set) var index: Int = 0

    private(set) var speed: Double = defaultSpeed

    private(set) var state = NovelState.loadWait

    public func load(raw: String) -> Result<EFNovelScript, ParseError> {
        state = .prepare
        index = 0

        return EFNovelScript.validate(rawText: raw)
    }

    public func start(script: EFNovelScript) -> AnyPublisher<DisplayEvent, Never> {
        switch state {
        case .prepare:
            displayEvents = script.displayEvents
            state = .running
            startLoop()
        default:
            print("now state is not prepare. now state: \(state)")
        }

        return internalOutputStream.eraseToAnyPublisher()
    }

    public func interrupt() {
        switch state {
        case .running, .pause:
            reset()
        default:
            print("now state is not running or pause. now state: \(state)")
        }
    }

    public func resume() {
        switch state {
        case .pause:
            state = .running
        default:
            print("now state is not pause. now state: \(state)")
        }
    }

    public func resume(at resumeIndex: Int) {
        switch state {
        case .pause:
            index = resumeIndex
            state = .running
        default:
            print("now state is not pause. now state: \(state)")
        }
    }

    public func reset() {
        state = .loadWait
        displayEvents = []
        index = 0
    }

    public func pause() {
        switch state {
        case .running:
            state = .pause
        default:
            print("now state is not running. now state: \(state)")
        }
    }

    public func showTextUntilWaitTag() {
        let offset: Int = index

        let checkListRange = displayEvents[offset..<displayEvents.count]
        let endIndex = checkListRange
            .firstIndex(where: { $0 == .tapWaitAndNewline || $0 == .tapWait || $0 == .newline })
            .map { $0 + index } ?? index

        let events = displayEvents[(index + 1)...(endIndex - 1)]

        index += events.count
        events.forEach { internalOutputStream.send($0) }
    }

    private func startLoop() {
        Task {
            // NOTE: wait for preparing subscribe stream client.
            try! await Task.sleep(nanoseconds: 100000)

            while (true) {
                switch state {
                case .running:
                    if displayEvents.isEmpty {
                        reset()
                        break
                    }

                    let event = displayEvents[index]

                    internalOutputStream.send(event)

                    // handle on interrupted
                    if state == .loadWait {
                        reset()
                        break
                    }

                    // finish
                    if displayEvents[index] == .end {
                        state = .prepare
                        break
                    }

                    index += 1
                    await handleEvent(event: event)
                case .prepare:
                    break
                case .loadWait:
                    break
                default:
                    // clock
                    try! await Task.sleep(nanoseconds: 10)
                    continue
                }

                // interrupt
                if state == .prepare { break }

                // clock
                try! await Task.sleep(nanoseconds: 10)
            }
        }
    }

    private func handleEvent(event: DisplayEvent) async {
        switch event {
        case .character(_):
            try! await Task.sleep(nanoseconds: UInt64(speed * Double(pow(10.0, 6))))
        case .delay(let duration):
            speed = duration
        case .resetDelay:
            speed = defaultSpeed
        case .tapWait, .tapWaitAndNewline:
            state = .pause
        default:
            print("default")
        }
    }
}