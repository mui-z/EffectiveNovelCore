//
// Created by osushi on 2026/03/21.
//

import Foundation

/// Owns playback **runtime state** (events buffer, cursor, async loop). Lives in the interface-adapter
/// layer with `EFNovelController` — not a Use Case (no orchestration-only, stateless `execute` API).
@MainActor
final class NovelPlaybackSession {

  private var displayEvents: [DisplayEvent] = []
  private var playbackState = NovelPlaybackState.initialLoadWait()
  private var loopTask: Task<Void, Never>?
  private var onEmit: ((DisplayEvent) -> Void)?

  var playbackIndex: Int { playbackState.index }
  var playbackSpeed: Double { playbackState.speed }
  var playbackDefaultSpeed: Double { playbackState.defaultSpeed }
  var playbackPhase: NovelState { playbackState.phase }

  func markPrepareForLoad() {
    cancelLoop()
    playbackState = .init(
      index: 0,
      phase: .prepare,
      speed: NovelPlaybackState.systemDefaultSpeed,
      defaultSpeed: NovelPlaybackState.systemDefaultSpeed
    )
    displayEvents = []
    onEmit = nil
  }

  func beginStreaming(script: EFNovelScript, onEmit: @escaping (DisplayEvent) -> Void) {
    guard playbackState.phase == .prepare else {
      print("current state must be prepare. but it is \(playbackState.phase)")
      return
    }
    cancelLoop()
    self.onEmit = onEmit
    displayEvents = script.displayEvents
    playbackState.phase = .running
    startLoop()
  }

  func interrupt() {
    cancelLoop()
    playbackState = .initialLoadWait()
    displayEvents = []
    onEmit = nil
  }

  func pause() {
    guard playbackState.phase == .running else { return }
    playbackState.phase = .pause
  }

  func resume() {
    guard playbackState.phase == .pause else { return }
    playbackState.phase = .running
  }

  func resume(at index: Int) {
    guard playbackState.phase == .pause else { return }
    playbackState.index = index
    playbackState.phase = .running
  }

  func showTextUntilWaitTag(onEmit: @escaping (DisplayEvent) -> Void) {
    guard playbackState.phase == .running else { return }
    guard let (slice, newIndex) = NovelPlaybackReducer.sliceUntilNextWait(
      in: displayEvents,
      fromIndex: playbackState.index
    ) else {
      return
    }
    for event in slice {
      onEmit(event)
    }
    playbackState.index = newIndex
  }

  private func cancelLoop() {
    loopTask?.cancel()
    loopTask = nil
  }

  private func startLoop() {
    cancelLoop()
    loopTask = Task { @MainActor [weak self] in
      guard let self else { return }
      try? await Task.sleep(nanoseconds: 100_000)
      while !Task.isCancelled {
        await self.runLoopIteration()
      }
    }
  }

  private func runLoopIteration() async {
    switch playbackState.phase {
    case .running:
      if displayEvents.isEmpty {
        applyLoadWaitReset()
        return
      }
      guard playbackState.index < displayEvents.count else {
        return
      }
      guard let emit = onEmit else { return }

      let event = displayEvents[playbackState.index]
      emit(event)

      if playbackState.phase == .loadWait {
        applyLoadWaitReset()
        return
      }

      playbackState.index += 1
      let effect = NovelPlaybackReducer.postEmit(state: &playbackState, emittedEvent: event)
      if effect.shouldClearScript {
        displayEvents = []
      }
      if let ns = effect.sleepNanoseconds {
        try? await Task.sleep(nanoseconds: ns)
      }

    case .prepare:
      break

    case .loadWait:
      break

    case .pause:
      try? await Task.sleep(nanoseconds: 10)
      return
    }

    if playbackState.phase == .prepare {
      cancelLoop()
      return
    }

    try? await Task.sleep(nanoseconds: 10)
  }

  private func applyLoadWaitReset() {
    playbackState = .initialLoadWait()
    displayEvents = []
  }
}
