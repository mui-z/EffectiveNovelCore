import Foundation

// Run the novel loop off the main thread so the main thread can spin `RunLoop.main`.
// Otherwise `DispatchSemaphore.wait()` on the main thread starves `MainActor`, and
// `EFNovelController` / `Task { @MainActor in ... }` never run (playback and Enter stall).
Thread {
  EffectiveNovelCLIRunner.run()
}.start()

RunLoop.main.run()
