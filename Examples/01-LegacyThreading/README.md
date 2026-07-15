# 01 - Legacy Threading

This example shows classic Foundation and Dispatch concurrency:

- `DispatchQueue` for serial work.
- `NSLock` for protecting shared mutable state.
- Run-loop-backed `Thread` scheduling with selector-based work dispatch.
- Foo/Bar coordination with a hand-rolled condition object.
- Foo/Bar coordination with `DispatchSemaphore`.
- A deadlock pattern detected with a timeout instead of hanging forever.

Run it from this folder:

```bash
swiftc *.swift -o /tmp/01_LegacyThreading && /tmp/01_LegacyThreading
```

Edit `selectedScenarios` in `main.swift` when you want to focus on one scenario at a time.

The output is intended for teaching. It shows that low-level threading gives you direct control, but also requires you to manage ordering, shared state, and lock correctness yourself.

## Original Source Mapping

- `SerialQueueExample.swift`: small DispatchQueue baseline for the legacy-threading lesson.
- `LockProtectedCounterExample.swift`: small NSLock baseline for the legacy-threading lesson.
- `RunLoopThreadPoolExample.swift`: based on `OriginalSamples/Threadpool/Threadpool.swift` and `OriginalSamples/Threadpool/Threadgroup.swift`. The course version keeps the run-loop thread and selector scheduling model, but uses dispatch groups and explicit stopping so the executable exits quickly.
- `FooBarConditionExample.swift`: based on `OriginalSamples/FooBar/FooBarAlternatively.swift`. The course version keeps the custom condition implementation and alternating `foo`/`bar` state machine, with fewer iterations and a completion wait.
- `FooBarSemaphoreExample.swift`: based on `OriginalSamples/FooBar/FooBarSemaphore.swift`. The course version keeps the paired semaphore handoff, runs it on dispatch queues, and waits for completion.
- `DeadlockTimeoutExample.swift`: based on `OriginalSamples/Deadlock.swift`. The course version keeps the inverted lock ordering, shortens the timing, and detects the deadlock with a timeout instead of sleeping for several seconds.
