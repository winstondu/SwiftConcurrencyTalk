# 12 - Sendable

This example compares a Swift 5 migration warning with a Swift 6-safe actor rewrite.

The Swift 5 target captures a mutable class instance in child tasks. Swift 5 mode allows it with a warning, but the code is race-prone because multiple tasks mutate `Counter.value`.

The Swift 6 target protects the shared mutable counter with an actor. Child tasks can share the actor reference, but every mutation runs through actor isolation. The example avoids `@unchecked Sendable` because the synchronization invariant belongs in the type.

## Targets

| Target | Source folder | Purpose |
| --- | --- | --- |
| `12_Sendable_Swift5` | `Swift5/` | Race-prone migration example that warns in Swift 5 |
| `12_Sendable_Swift6` | `Swift6/` | Actor-isolated rewrite that builds cleanly in Swift 6 |

Build and run with Xcode:

```sh
xcodebuild -project ConcurrencyInSwift.xcodeproj -scheme 12_Sendable_Swift5 -configuration Debug -derivedDataPath build/DerivedData build
./build/DerivedData/Build/Products/Debug/12_Sendable_Swift5

xcodebuild -project ConcurrencyInSwift.xcodeproj -scheme 12_Sendable_Swift6 -configuration Debug -derivedDataPath build/DerivedData build
./build/DerivedData/Build/Products/Debug/12_Sendable_Swift6
```

Edit each target's `main.swift` and update `selectedScenarios` to choose which examples run.
