# Concurrency In Swift

This project is a runnable Swift concurrency course. It keeps one Xcode project, `ConcurrencyInSwift.xcodeproj`, and uses separate command-line targets for the examples so each concept can be built and run independently.

The course has two goals:

- Teach Swift concurrency from legacy threading through actors, task inheritance, Swift 6 scheduling, `NonisolatedNonsending`, and `Sendable`.
- Preserve the original exploratory `00_OriginalSamples` code by turning every useful idea from it into a focused course scenario.

## Main File Structure

Every course target follows the same shape:

- `main.swift` is a launcher only.
- Scenario implementation lives in separate files named after the concept.
- Each scenario exposes one clear `run...Example()` function.
- During a lesson, edit the `selectedScenarios` array in `main.swift` to run only the scenario or scenarios being discussed.

Example:

```swift
fileprivate enum Scenario: Int {
    case serialQueue
    case lockProtectedCounter
    case deadlockTimeout
}

fileprivate let selectedScenarios: [Scenario] = [
    .serialQueue,
    .lockProtectedCounter
]

print("Legacy threading examples")

if selectedScenarios.contains(.serialQueue) {
    runSerialQueueExample()
}

if selectedScenarios.contains(.lockProtectedCounter) {
    runLockProtectedCounterExample()
}

if selectedScenarios.contains(.deadlockTimeout) {
    runDeadlockTimeoutExample()
}

print("Done")
```

This keeps target entry points readable and prevents one large `main.swift` from hiding the individual concepts.

## Course Structure

| Order | Concept | Scheme(s) | Main file role |
| --- | --- | --- | --- |
| 00 | Original exploratory samples | `00_OriginalSamples` | Archive target for the pre-course code |
| 01 | Legacy threading, locks, thread pools, semaphores | `01_LegacyThreading` | Launcher for individual Foundation/Dispatch scenarios |
| 02 | Task basics | `02_TaskBasics` | Launcher for sequential async work and `Task.value` |
| 03 | `async let` | `03_AsyncLet` | Launcher for fixed-width child task examples |
| 04 | Task groups | `04_TaskGroups` | Launcher for dynamic work, bounded requests, and tree traversal |
| 05 | Cancellation | `05_Cancellation` | Launcher for timeout and cooperative cancellation |
| 06 | Actors | `06_Actors` | Launcher for actor-isolated state examples |
| 07 | Actor reentrancy | `07_ActorReentrancy` | Launcher for reentrant and non-suspending variants |
| 08 | Global actors | `08_GlobalActors` | Launcher for global actor and custom executor scenarios |
| 09 | Task inheritance | `09_TaskInheritance` | Launcher for inherited task and global-actor gotcha scenarios |
| 10 | Swift 5 vs Swift 6 scheduling | `10_TaskScheduling_Swift5`, `10_TaskScheduling_Swift6` | Variant launchers under one concept README |
| 11 | `NonisolatedNonsending` | `11_Nonisolated_Legacy`, `11_Nonisolated_Modern` | Variant launchers under one concept README |
| 12 | `Sendable` | `12_Sendable_Swift5`, `12_Sendable_Swift6` | Variant launchers under one concept README |
| 13 | Actor capture in framework callbacks | `13_ActorCapture_iOS` | iOS app demonstrating `AVAudioEngine` tap callbacks |

## Original Sample Allocation

| Original file | Course location | Use |
| --- | --- | --- |
| `OriginalSamples/Deadlock.swift` | `Examples/01-LegacyThreading` | Lock-order deadlock with timeout |
| `OriginalSamples/Threadpool/Threadpool.swift` | `Examples/01-LegacyThreading` | Manual thread pool contrast |
| `OriginalSamples/Threadpool/Threadgroup.swift` | `Examples/01-LegacyThreading` | Manual thread group contrast |
| `OriginalSamples/FooBar/FooBarAlternatively.swift` | `Examples/01-LegacyThreading` | Condition-style alternating output |
| `OriginalSamples/FooBar/FooBarSemaphore.swift` | `Examples/01-LegacyThreading` | Semaphore alternating output |
| `OriginalSamples/LoadRequests.swift` | `Examples/04-TaskGroups` | Bounded dynamic request loading |
| `OriginalSamples/FBView.swift` | `Examples/04-TaskGroups` | Tree traversal as dynamic work |
| `OriginalSamples/SpecialActor.swift` | `Examples/08-GlobalActors` | Custom executor-backed global actor |
| `OriginalSamples/main.swift` | `Examples/01-LegacyThreading` | Original `runThreadGroup()` idea folded into the manual thread group scenario |

## Build

List schemes:

```sh
xcodebuild -list -project ConcurrencyInSwift.xcodeproj
```

Build one example:

```sh
xcodebuild -project ConcurrencyInSwift.xcodeproj -scheme 04_TaskGroups -configuration Debug -derivedDataPath build/DerivedData build
```

Run it:

```sh
./build/DerivedData/Build/Products/Debug/04_TaskGroups
```
