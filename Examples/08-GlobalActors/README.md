# 08 - Global Actors

This command-line example defines a custom global actor named `AuditActor`.

`AuditLog` is isolated to that global actor, so every call to `record(_:)` and `snapshot()` is serialized through the same actor instance, even when several tasks process orders concurrently.

`CustomExecutorOtherActorExample.swift` maps the original `OriginalSamples/SpecialActor.swift` sample into this course section. It keeps the same core pieces:

- `CustomExecutor: SerialExecutor`
- `OtherActor: GlobalActor`
- `OtherActor.unownedExecutor`
- `generateTaskOnSpecialExecutor`

The course version avoids `Thread.current` in async code. It uses `OtherActor.assertIsolated()` and deterministic printed markers instead, then awaits every task value so the command-line program exits.

Run it with:

```sh
swiftc *.swift -o /tmp/global-actors-example
/tmp/global-actors-example
```

Edit the `selectedScenarios` array in `main.swift` to choose which scenarios run.
