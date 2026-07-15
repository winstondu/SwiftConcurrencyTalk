# 09 - Task Inheritance

This target demonstrates what unstructured tasks inherit from the place where they are created.

The important distinction is between `Task { ... }` and `Task.detached { ... }`.

`Task { ... }` creates an unstructured task, but it can still inherit context from the caller. In an actor-isolated context, that means the task body may run with the same actor isolation. It also inherits task-local values such as the `traceID` in `TaskInheritanceExample.swift`.

`Task.detached { ... }` starts outside the caller's task context. It does not inherit task-local values, priority, cancellation, or actor isolation in the same way. When detached work needs actor-isolated state, it must call back into the actor with `await`.

## Launchers

`main.swift` uses a `Scenario` enum plus a `selectedScenarios` array:

```swift
fileprivate let selectedScenarios: [Scenario] = [
    .globalActorClassTaskInheritance
]
```

Edit `selectedScenarios` when teaching a specific case. The intentionally crashing scenario remains an enum case, but it is not included by default.

## Baseline: `Task` vs `Task.detached`

`runTaskInheritanceExample()` uses the `Recorder` actor.

Inside the actor, `Task { ... }` can append to the actor-isolated `messages` array directly, and it sees the inherited task-local `traceID`.

The detached task cannot directly mutate `messages`. It calls `await self.recordFromDetached(...)`, which hops back to the actor. It also sees the default task-local value instead of the caller's `traceID`.

This is the high-level rule:

- `Task { ... }` can inherit the caller's task and isolation context.
- `Task.detached { ... }` starts independently and must explicitly cross isolation boundaries.

## Global-Actor-Isolated Class

`runGlobalActorClassTaskInheritanceExample()` uses a class annotated with a custom global actor:

```swift
@TaskInheritanceActor
final class GlobalActorIsolatedClass { ... }
```

Methods on that class are isolated to `TaskInheritanceActor`. A plain `Task { ... }` created inside one of those methods inherits that global actor isolation, so the task body can call:

```swift
TaskInheritanceActor.assertIsolated()
```

This case is intentionally a class, not an actor instance. The class itself does not provide actor instance isolation; the global actor annotation does.

## Actor Instance Gotcha

`runActorInstanceTaskInheritanceGotchaExample()` and `runActorInstanceTaskInheritanceCrashExample()` show the more surprising actor-instance case.

A `Task { ... }` created inside an actor method is not isolated to that actor just because it was written lexically inside the actor method. The task body has to actually use `self` or actor-isolated state in a way the compiler recognizes as isolated to that actor.

The safe launcher shows the positive case:

```swift
Task {
    self.assertIsolated()
    count += 1
}
```

That task body directly references `self`, so it runs isolated to the actor instance and can mutate `count`.

The crash launcher shows the negative case:

```swift
let actor = self
Task {
    actor.assertIsolated()
}
```

This compiles, but it traps at runtime with an incorrect actor executor assertion. The task body references a local alias named `actor`, not `self`, so the task closure does not inherit the actor instance isolation that `actor.assertIsolated()` expects.

Leave `.actorInstanceTaskInheritanceCrash` out of `selectedScenarios` unless you specifically want to demonstrate the failure.

## Explicit Global Actor Annotation

`runExplicitGlobalActorTaskAnnotationExample()` uses:

```swift
Task { @TaskInheritanceActor in
    TaskInheritanceActor.assertIsolated()
}
```

This is the clearest spelling when the task body must run on a particular global actor. It is easier to teach and audit than relying on implicit inheritance.

Original-source mapping: this task-closure annotation overlaps with the `Task { @OtherActor in ... }` part of `OriginalSamples/SpecialActor.swift`. The custom executor and `OtherActor.unownedExecutor` parts of that original sample live in `Examples/08-GlobalActors/CustomExecutorOtherActorExample.swift`.

## Nonisolated Method Gotcha

`runNonisolatedTaskCreationGotchaExample()` starts on `MainActor`, then calls a `nonisolated` method that creates a task.

The key point is that a task created inside a `nonisolated` method should not be treated as isolated just because the caller happened to be isolated. If the new task needs a specific actor, say so explicitly with an actor annotation or hop with `await Actor.run { ... }` where appropriate.

## What This Target Does Not Show

These examples avoid relying on nondeterministic print order. The teaching signal is whether the code can assert isolation or access actor-isolated state, not whether the letters `a`, `b`, and `c` happen to print in one order on one run.

There is one intentionally crashing scenario. It exists to prove the actor-instance gotcha in executable code, and it stays out of `selectedScenarios` by default.

Edit the `selectedScenarios` array in `main.swift` to choose which scenarios are active.

Run it with:

```sh
swiftc *.swift -o task-inheritance
./task-inheritance
```
