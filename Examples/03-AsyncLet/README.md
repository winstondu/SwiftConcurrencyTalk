# 03 - Async Let

This example shows `async let` for a fixed set of parallel child operations, plus the `async let` / `Task` actor-inheritance gotcha from the course notes.

Run it from this folder:

```bash
swiftc *.swift -o /tmp/03_AsyncLet && /tmp/03_AsyncLet
```

Edit `selectedScenarios` in `main.swift` when you want to focus on one scenario at a time.

`async let` starts child work immediately and waits when the values are read. It is a good fit when you know the number of child operations at compile time, such as loading a user, settings, and inbox count for one screen.

## Scenarios

| Scenario | File | Purpose |
| --- | --- | --- |
| `.fixedParallelWork` | `FixedParallelWorkExample.swift` | Shows ordinary fixed-width parallel child work. |
| `.regularTaskMainActorInheritance` | `AsyncLetTaskInheritanceGotchaExample.swift` | Shows that a regular `Task { ... }` created in a `@MainActor` function inherits MainActor isolation. |
| `.asyncLetTaskMainActorInheritanceCrash` | `AsyncLetTaskInheritanceGotchaExample.swift` | Shows the gotcha from `Structured Concurrency Gotchas.md`: wrapping the same `Task { ... }` creation in `async let` does not inherit MainActor isolation. This scenario intentionally traps and is excluded from `selectedScenarios` by default. |

Leave `.asyncLetTaskMainActorInheritanceCrash` out of `selectedScenarios` unless you specifically want to demonstrate the runtime failure.
