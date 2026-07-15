# 10 - Swift 6 Scheduling

This example compares scheduling style across Swift language modes.

The Swift 5 target shows the older spelling often used when a `@MainActor` type wanted async work to run outside actor-isolated state: put the work in a `nonisolated async` helper.

The Swift 6 target uses `@concurrent nonisolated` for async work that is intentionally scheduled away from the caller's actor isolation. The distinction matters with modern Swift 6 settings such as `NonisolatedNonsendingByDefault`: plain `nonisolated async` can inherit the caller's isolation, while `@concurrent` says the helper is independent and may run concurrently.

## Targets

| Target | Source folder | Purpose |
| --- | --- | --- |
| `10_TaskScheduling_Swift5` | `Swift5/` | Swift 5 baseline using `nonisolated async` |
| `10_TaskScheduling_Swift6` | `Swift6/` | Swift 6 version using `@concurrent nonisolated` |

Build and run with Xcode:

```sh
xcodebuild -project ConcurrencyInSwift.xcodeproj -scheme 10_TaskScheduling_Swift5 -configuration Debug -derivedDataPath build/DerivedData build
./build/DerivedData/Build/Products/Debug/10_TaskScheduling_Swift5

xcodebuild -project ConcurrencyInSwift.xcodeproj -scheme 10_TaskScheduling_Swift6 -configuration Debug -derivedDataPath build/DerivedData build
./build/DerivedData/Build/Products/Debug/10_TaskScheduling_Swift6
```

Edit each target's `main.swift` and update `selectedScenarios` to choose which examples run.
