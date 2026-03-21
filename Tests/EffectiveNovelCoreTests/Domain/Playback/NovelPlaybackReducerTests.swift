//
// Created by osushi on 2026/03/21.
//

import XCTest
@testable import EffectiveNovelCore

final class NovelPlaybackReducerTests: XCTestCase {

  func testPostEmit_characterSleepsWithCurrentSpeed() {
    var state = NovelPlaybackState(
      index: 1,
      phase: .running,
      speed: 10,
      defaultSpeed: 90
    )
    let effect = NovelPlaybackReducer.postEmit(state: &state, emittedEvent: .character(char: "a"))
    XCTAssertEqual(effect.sleepNanoseconds, 10_000_000)
    XCTAssertFalse(effect.shouldClearScript)
    XCTAssertEqual(state.phase, .running)
  }

  func testPostEmit_delayUpdatesSpeed() {
    var state = NovelPlaybackState(
      index: 0,
      phase: .running,
      speed: 90,
      defaultSpeed: 90
    )
    let effect = NovelPlaybackReducer.postEmit(state: &state, emittedEvent: .delay(speed: 5))
    XCTAssertNil(effect.sleepNanoseconds)
    XCTAssertEqual(state.speed, 5)
  }

  func testPostEmit_tapWaitPauses() {
    var state = NovelPlaybackState(
      index: 0,
      phase: .running,
      speed: 90,
      defaultSpeed: 90
    )
    let effect = NovelPlaybackReducer.postEmit(state: &state, emittedEvent: .tapWait)
    XCTAssertEqual(state.phase, .pause)
    XCTAssertFalse(effect.shouldClearScript)
  }

  func testPostEmit_endResetsAndClearsScript() {
    var state = NovelPlaybackState(
      index: 3,
      phase: .running,
      speed: 5,
      defaultSpeed: 5
    )
    let effect = NovelPlaybackReducer.postEmit(state: &state, emittedEvent: .end)
    XCTAssertTrue(effect.shouldClearScript)
    XCTAssertEqual(state, .initialLoadWait())
  }

  func testSliceUntilNextWaitTag() {
    let events: [DisplayEvent] = [
      .character(char: "a"),
      .tapWait,
      .character(char: "b")
    ]
    let result = NovelPlaybackReducer.sliceUntilNextWait(in: events, fromIndex: 0)
    XCTAssertNotNil(result)
    XCTAssertEqual(Array(result!.slice), [.character(char: "a")])
    XCTAssertEqual(result!.newIndex, 1)
  }
}
