//
// Created by osushi on 2026/03/21.
//

public struct NovelPlaybackState: Equatable, Sendable {
  public var index: Int
  public var phase: NovelState
  public var speed: Double
  public var defaultSpeed: Double

  public static let systemDefaultSpeed: Double = 90.0

  public init(
    index: Int,
    phase: NovelState,
    speed: Double,
    defaultSpeed: Double
  ) {
    self.index = index
    self.phase = phase
    self.speed = speed
    self.defaultSpeed = defaultSpeed
  }

  public static func initialLoadWait() -> Self {
    .init(
      index: 0,
      phase: .loadWait,
      speed: systemDefaultSpeed,
      defaultSpeed: systemDefaultSpeed
    )
  }
}
