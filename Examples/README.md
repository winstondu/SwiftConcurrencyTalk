# Swift Concurrency Course Examples

This directory contains one runnable command-line example per course topic. The repo still uses one Xcode project, `ConcurrencyInSwift.xcodeproj`, but each example is its own target and shared scheme so it can be built and run independently from the command line.

## Course Order

| Order | Topic | Scheme / Target | Swift settings |
| --- | --- | --- | --- |
| 01 | Legacy threading, locks, and deadlock | `01_LegacyThreading` | Swift 5, complete strict concurrency |
| 02 | Task basics and `Task.value` | `02_TaskBasics` | Swift 6, complete strict concurrency |
| 03 | `async let` for fixed parallelism | `03_AsyncLet` | Swift 6, complete strict concurrency |
| 04 | Task groups for dynamic parallelism | `04_TaskGroups` | Swift 6, complete strict concurrency |
| 05 | Cooperative cancellation | `05_Cancellation` | Swift 6, complete strict concurrency |
| 06 | Actors and serialized state | `06_Actors` | Swift 6, complete strict concurrency |
| 07 | Actor reentrancy across `await` | `07_ActorReentrancy` | Swift 6, complete strict concurrency |
| 08 | Global actors | `08_GlobalActors` | Swift 6, complete strict concurrency |
| 09 | Task inheritance vs detached tasks | `09_TaskInheritance` | Swift 6, complete strict concurrency |
| 10a | Swift 5 scheduling baseline | `10_TaskScheduling_Swift5` | Swift 5, complete strict concurrency |
| 10b | Swift 6 scheduling / `@concurrent` | `10_TaskScheduling_Swift6` | Swift 6, complete strict concurrency |
| 11a | Legacy `nonisolated async` behavior | `11_Nonisolated_Legacy` | Swift 5, complete strict concurrency |
| 11b | `NonisolatedNonsendingByDefault` | `11_Nonisolated_Modern` | Swift 6, complete strict concurrency, upcoming feature flag |
| 12a | Sendable migration pressure | `12_Sendable_Swift5` | Swift 5, complete strict concurrency |
| 12b | Sendable-safe actor rewrite | `12_Sendable_Swift6` | Swift 6, complete strict concurrency |
| 13 | Actor capture in framework callbacks | `13_ActorCapture_iOS` | Swift 6, complete strict concurrency, iOS only |

## Build And Run

List the available schemes:

```sh
xcodebuild -list -project ConcurrencyInSwift.xcodeproj
```

Build one example:

```sh
xcodebuild -project ConcurrencyInSwift.xcodeproj -scheme 04_TaskGroups -configuration Debug -derivedDataPath build/DerivedData build
```

Run the executable:

```sh
./build/DerivedData/Build/Products/Debug/04_TaskGroups
```

Build every example:

```sh
for scheme in \
  01_LegacyThreading \
  02_TaskBasics \
  03_AsyncLet \
  04_TaskGroups \
  05_Cancellation \
  06_Actors \
  07_ActorReentrancy \
  08_GlobalActors \
  09_TaskInheritance \
  10_TaskScheduling_Swift5 \
  10_TaskScheduling_Swift6 \
  11_Nonisolated_Legacy \
  11_Nonisolated_Modern \
  12_Sendable_Swift5 \
  12_Sendable_Swift6
do
  xcodebuild -project ConcurrencyInSwift.xcodeproj -scheme "$scheme" -configuration Debug -derivedDataPath build/DerivedData build
done
```

`13_ActorCapture_iOS` is intentionally not included in that macOS command-line loop. Build it for the iOS simulator:

```sh
xcodebuild -project ConcurrencyInSwift.xcodeproj -scheme 13_ActorCapture_iOS -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath build/DerivedData build
```

Each topic folder also has a short README for the specific concept demonstrated by that target.

## Example Structure

Keep `main.swift` as a typed scenario selector, not as the lesson implementation. Each independently teachable scenario should live in its own `.swift` file with one clear entry point, usually named `run...Example()`.

`main.swift` should define a file-private integer-backed `Scenario` enum, a `selectedScenarios` array near the top, and `contains` checks for the runnable scenarios:

```swift
fileprivate enum Scenario: Int {
    case dynamicParallelWork
    case boundedRequestLoading
}

fileprivate let selectedScenarios: [Scenario] = [
    .dynamicParallelWork
]

if selectedScenarios.contains(.dynamicParallelWork) {
    await runDynamicParallelWorkExample()
}

if selectedScenarios.contains(.boundedRequestLoading) {
    await runBoundedRequestLoadingExample()
}
```

That keeps each target runnable by default while making it easy to switch scenarios without editing the executable control flow.
