//
// Created by osushi on 2026/03/21.
//

public enum NovelPlaybackReducer {

  public struct PostEmitEffect: Equatable, Sendable {
    public var sleepNanoseconds: UInt64?
    public var shouldClearScript: Bool

    public init(sleepNanoseconds: UInt64? = nil, shouldClearScript: Bool = false) {
      self.sleepNanoseconds = sleepNanoseconds
      self.shouldClearScript = shouldClearScript
    }

    public static let none = PostEmitEffect()
  }

  /// Semantic handling after an event was emitted and `state.index` was advanced past that event.
  public static func postEmit(
    state: inout NovelPlaybackState,
    emittedEvent: DisplayEvent
  ) -> PostEmitEffect {
    switch emittedEvent {
    case .character:
      return PostEmitEffect(sleepNanoseconds: nanosecondsForMilliseconds(state.speed))
    case .delay(let duration):
      state.speed = duration
      return .none
    case .setDefaultDelay(let duration):
      state.defaultSpeed = duration
      state.speed = duration
      return .none
    case .resetDelay:
      state.speed = state.defaultSpeed
      return .none
    case .tapWait, .tapWaitAndNewline:
      state.phase = .pause
      return .none
    case .end:
      state = .initialLoadWait()
      return PostEmitEffect(shouldClearScript: true)
    case .sleep(let duration):
      return PostEmitEffect(sleepNanoseconds: nanosecondsForMilliseconds(duration))
    case .newline, .clear:
      return .none
    }
  }

  private static func nanosecondsForMilliseconds(_ ms: Double) -> UInt64 {
    UInt64(max(0, ms * 1_000_000))
  }

  private static func isWaitBoundary(_ event: DisplayEvent) -> Bool {
    switch event {
    case .tapWait, .tapWaitAndNewline, .end:
      return true
    default:
      return false
    }
  }

  /// Events to emit in bulk (no per-event timing), and the index after the slice (first wait tag or equivalent).
  /// Mirrors legacy `showTextUntilWaitTag` range logic; returns `nil` if the legacy code would have trapped.
  public static func sliceUntilNextWait(
    in events: [DisplayEvent],
    fromIndex index: Int
  ) -> (slice: ArraySlice<DisplayEvent>, newIndex: Int)? {
    guard index >= 0, index < events.count else { return nil }
    let searchRange = index ..< events.count
    guard let waitIndex = events[searchRange].firstIndex(where: isWaitBoundary) else {
      return nil
    }
    let endIndex = waitIndex - 1
    guard index <= endIndex, endIndex < events.count else { return nil }
    let newIndex = index + (endIndex - index + 1)
    return (events[index ... endIndex], newIndex)
  }
}
