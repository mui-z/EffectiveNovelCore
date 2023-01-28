//
// Created by osushi on 2022/09/23.
//

import Foundation
import Combine
import Factory

enum NovelState {
    case loadWait, prepare, running, pause
}

protocol Controller {
    func load(raw: String) -> ValidateResult<EFNovelScript, [ValidationError]>
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

public class NovelController: Controller {

    public init() {
    }

    @Injected(Container.validateScriptUseCase)
    var validateScriptUseCase: ValidateScriptUseCaseProtocol
	
    private let semaphore = DispatchSemaphore(value: 1)

    private var privateOutputStream = PassthroughSubject<DisplayEvent, Never>()

    private var displayEvents: [DisplayEvent] = []

    private var cancellable: Set<AnyCancellable> = []

    private(set) var index: Int = 0

    private(set) lazy var defaultSpeed: Double = systemDefaultSpeed

    private(set) lazy var speed: Double = systemDefaultSpeed

    private(set) var state = NovelState.loadWait

    public func load(raw: String) -> ValidateResult<EFNovelScript, [ValidationError]> {
		defer {
			semaphore.signal()
		}
		semaphore.wait()
		
        state = .prepare
        index = 0

        return validateScriptUseCase.validate(rawAllString: raw)
    }

    public func start(script: EFNovelScript) -> AnyPublisher<DisplayEvent, Never> {
        defer {
            semaphore.signal()
        }
        semaphore.wait()
		
        switch state {
        case .prepare:
            displayEvents = script.displayEvents
            state = .running
            startLoop()
        default:
            print("now state is not prepare. now state: \(state)")
        }

        return privateOutputStream
            .delay(for: 0.1, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    public func interrupt() {
        defer {
            semaphore.signal()
        }
        semaphore.wait()
		
        switch state {
        case .running, .pause:
            reset()
        default:
            print("now state is not running or pause. now state: \(state)")
        }
    }

    public func resume() {
        defer {
            semaphore.signal()
        }
        semaphore.wait()
		
        switch state {
        case .pause:
            speed = getLatestSpeedFromIndex()
            state = .running
        default:
            print("now state is not pause. now state: \(state)")
        }
    }

    public func resume(at resumeIndex: Int) {
        defer {
            semaphore.signal()
        }
        semaphore.wait()
		
        switch state {
        case .pause:
            index = resumeIndex
            speed = getLatestSpeedFromIndex()
            state = .running
        default:
            print("now state is not pause. now state: \(state)")
        }
    }

    public func pause() {
        defer {
            semaphore.signal()
        }
        semaphore.wait()
		
        switch state {
        case .running:
            state = .pause
        default:
            print("now state is not running. now state: \(state)")
        }
    }

    public func showTextUntilWaitTag() {
        defer {
            semaphore.signal()
        }
        semaphore.wait()
		
        guard state == .running else { return }

        let offset: Int = index

        let checkListRange = displayEvents[offset ..< displayEvents.count]
        let endIndex = checkListRange
            .firstIndex(where: { $0 == .tapWaitAndNewline || $0 == .tapWait || $0 == .end })
            .map { $0 - 1 }!

        // TODO: use to semaphore
        if index <= endIndex {
            let events = displayEvents[index...endIndex]

            index += events.count
            events.forEach { privateOutputStream.send($0) }
        }

    }
	
    private func reset() {
        state = .loadWait
        displayEvents = []
        index = 0
        defaultSpeed = systemDefaultSpeed
        speed = systemDefaultSpeed
    }


    private func startLoop() {
        Task {
            // NOTE: wait for preparing subscribe stream client.
            try! await Task.sleep(nanoseconds: 100000)

            while true {
                switch state {
                case .running:
                    if displayEvents.isEmpty {
                        reset()
                        break
                    }

                    let event = displayEvents[index]

                    privateOutputStream.send(event)

                    // handle for interrupted
                    if state == .loadWait {
                        reset()
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
        case .character:
            try! await Task.sleep(nanoseconds: UInt64(speed * Double(pow(10.0, 6))))
        case .delay(let duration):
            speed = duration
        case .setDefaultDelay(let duration):
            defaultSpeed = duration
            speed = duration
        case .resetDelay:
            speed = defaultSpeed
        case .tapWait, .tapWaitAndNewline:
            state = .pause
        case .end:
            reset()
        case .sleep(let duration):
            try! await Task.sleep(nanoseconds: UInt64(duration * Double(pow(10.0, 6))))
        default:
            break
        }
    }

    private let systemDefaultSpeed: Double = 90
  
    private func getLatestSpeedFromIndex() -> Double {
        let speedTagUntilIndex = displayEvents[0...index]
            .filter { isDipslayEvent($0) }
            .last
        
        if let speedTagUntilIndex = speedTagUntilIndex {
            switch speedTagUntilIndex {
                case .delay(let speed):
                    return speed
                default:
                    fatalError("unknown error.")
            }
        } else {
            return defaultSpeed
        }
    }
    
    // FIXME: add equatable operator override. and move to domain.
    private func isDipslayEvent(_ a: DisplayEvent) -> Bool {
        switch a {
            case .delay(_):
                return true
            default:
                return false
        }
    }
}
