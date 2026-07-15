# 11 - Nonisolated Nonsending

This example compares legacy `nonisolated async` behavior with Swift 6's `NonisolatedNonsendingByDefault` behavior.

The legacy target passes a non-`Sendable` class instance from a `@MainActor` method into a `nonisolated async` helper. Swift 5 mode allows this as migration-era code, while Swift 6 mode without the upcoming feature rejects it because the non-`Sendable` value is sent away from main-actor isolation.

The modern target uses the same source shape, but is built with Swift 6 and `NonisolatedNonsendingByDefault` enabled. With that feature enabled, the plain `nonisolated async` helper does not require sending the non-`Sendable` value away from the caller's isolation. If a helper should actually run concurrently, make that explicit with `@concurrent` and pass only `Sendable` inputs.

## Targets

| Target | Source folder | Purpose |
| --- | --- | --- |
| `11_Nonisolated_Legacy` | `Legacy/` | Swift 5 legacy behavior |
| `11_Nonisolated_Modern` | `Modern/` | Swift 6 with `NonisolatedNonsendingByDefault` |

Build and run with Xcode:

```sh
xcodebuild -project ConcurrencyInSwift.xcodeproj -scheme 11_Nonisolated_Legacy -configuration Debug -derivedDataPath build/DerivedData build
./build/DerivedData/Build/Products/Debug/11_Nonisolated_Legacy

xcodebuild -project ConcurrencyInSwift.xcodeproj -scheme 11_Nonisolated_Modern -configuration Debug -derivedDataPath build/DerivedData build
./build/DerivedData/Build/Products/Debug/11_Nonisolated_Modern
```

Edit each target's `main.swift` and update `selectedScenarios` to choose which examples run.
