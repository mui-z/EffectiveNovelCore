# EffectiveNovelCLI

Terminal demo for [EffectiveNovelCore](../../README.md). Behaviour matches [EffectiveNovelReader](../EffectiveNovelReader/) (tap → **Enter**).

## Requirements

- macOS 10.15+ (same as the core package)
- Swift 6

## Script

- **[sample.novel](sample.novel)** — short script with fast typing delay and a `[tw]` pause. If your current working directory contains `sample.novel`, it is loaded automatically.
- **Custom file:** `swift run EffectiveNovelCLI /path/to/script.novel`
- If neither applies, the built-in long sample (same idea as the iOS reader) is used.

Stderr prints `Script: …` so you can see which source was loaded.

## Run

From **this directory** (`Examples/EffectiveNovelCLI`) so `sample.novel` is found:

```bash
swift run EffectiveNovelCLI
```

Or run the binary at `.build/debug/EffectiveNovelCLI` from the same folder, or pass an explicit script path.

## Controls

- **Enter** — same as a **tap** in the iOS reader:
  - After `tapWait` / `tapWaitAndNewline`, press Enter to continue.
  - Otherwise Enter runs “show until next wait tag” (fast-forward chunk), like tapping outside a wait.

Output is stdout; `[cl]` uses an ANSI clear (terminal-dependent).

## Implementation note

`EFNovelController` is `@MainActor`. The CLI runs its blocking work on a **background thread** and keeps the **main thread** in `RunLoop.main.run()` so MainActor jobs (playback, Enter handling) actually run. Blocking the main thread with `DispatchSemaphore.wait()` would deadlock that pipeline.

## Package layout

- Depends on the core library via `.package(path: "../..")` (repository root).
