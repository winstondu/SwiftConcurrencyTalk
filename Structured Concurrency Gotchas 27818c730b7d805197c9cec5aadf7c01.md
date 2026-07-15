# Structured Concurrency Gotchas

### 1. `async-let` DOES NOT inherit the actor from the caller context

```swift
// This crashes
@MainActor func outputZero() async -> Int {
    async let task = Task {
        MainActor.assertIsolated()
        print("task completed")
        return 0
    }
    return await task.value
}
```

```swift
// This does not crash
@MainActor func outputZero() async -> Int {
    let task = Task {
        MainActor.assertIsolated()
        print("task completed")
        return 0
    }
    return await task.value
}
```

### 2. Task closures created in an ***actor’s*** instance methods are automatically isolated to that actor ONLY if `self`  is used in the body

From: https://forums.swift.org/t/closure-isolation-control/70378/7

> A closure in an actor method that's passed to the `Task` initializer will currently only be isolated to `self` if there's a reference to `self` in the body of the closure (including an implicit reference to `self` via a member reference.) Note in particular that putting `self` in the explicit captures list **is *not* sufficient** to make isolation be inherited; you need an actual reference in the body of the closure, such as `_ = self`.
> 
> 
> I think most of us working on the language are in agreement that this rule is pretty baroque and confusing, which is why this proposal aims to change it. But that's the current rule.
> 

The original discussion back in early 2021:

From: https://forums.swift.org/t/se-0304-4th-review-structured-concurrency/50281/43

> For the subtask to be within the actor, it needs an `isolated` parameter of the actor's type. Isolation guarantees are **statically determined** by `isolated` parameters; they're not dynamically determined or else we wouldn't be able to check them statically.
> 

This means while isolated methods in **classes** have Tasks automatically capture the isolation, this is not the case for actors.

e.g. 

```swift
@ExampleActor
class ExampleClass {
    
    func startTasksIsolated(run: Int) {
        print("\nRun \(run) ", terminator: "")
        let closure: @Sendable () -> Void  = {
            ExampleActor.shared.assertIsolated()
        }
        let x = Task {
            closure() // No crash!
            print("a", terminator: "")
        }
        let y = Task {
            closure() // No crash!
            print("b", terminator: "")
        }
        let z = Task {
            closure() // No crash!
            print("c", terminator: "")
        }
    }
}
```

### 3. Tasks created in a nonisolated function DO NOT inherit concurrency.

```swift
class Examples: @unchecked Sendable {
    nonisolated func startTasksIsolatedAsync() async {
        MainActor.assertIsolated()
        print("We're on the main actor") // Even if we get here...
        Task {
            MainActor.assertIsolated() // ... we still crash here
        }
    }
    
    nonisolated func startTasksIsolatedSync() {
        MainActor.assertIsolated()
        print("We're on the main actor") // Even if we get here...
        Task {
            MainActor.assertIsolated() // ... we still crash here
        }
    }
}
```

### 4. In Swift 6, Tasks on the same actor execute in order of creation (SE-431) — with ONE caveat

Concretely, all of these mean:

```swift
@globalActor
actor ExampleActor : GlobalActor {
    static let shared = ExampleActor()
    private static let executor = ExampleActor.shared.unownedExecutor;
    
		// No guaranteed order 
		// -- the Tasks NEVER run on ExampleActor
    func startTasksIsolated(run: Int) {
        print("\nRun \(run) ", terminator: "")
        let x = Task { print("a", terminator: "") }
        let y = Task { print("b", terminator: "") }
        let z = Task { print("c", terminator: "") }
    }
    
 		// Guaranteed order (in Swift 6)
 		// -- Due to capture of self in the Task, the Tasks run on ExampleActor. 
 		// -- If we are in Swift 6 (with SE-431) they must also start on ExampleActor
    func startTasksIsolatedWithSelfCapture(run: Int)  {
        print("\nRun \(run) ", terminator: "")
        let x = Task {
            self.assertIsolated() // This capture of self forces order
            print("a", terminator: "")
        }
        let y = Task {
            self.assertIsolated() 
            print("b", terminator: "")
        }
        let z = Task {
            self.assertIsolated()
            print("c", terminator: "")
        }
    }
    
    // Not Guaranteed order 
 		// -- the Tasks run on ExampleActor
 		// -- but the tasks MAY start on MainActor!!!
 		// Note: As of 6.2 there may not be an optimization
    func startTasksIsolatedWithSelfCaptureStartOnMain(run: Int)  {
        print("\nRun \(run) ", terminator: "")
				let x = Task {
            await MainActor.run {
                print("a", terminator: "")
            }
            self.assertIsolated()
        }
        let y = Task {
            await MainActor.run {
                print("b", terminator: "")
            }
            self.assertIsolated()
        }
        let z = Task {
            await MainActor.run {
                print("c", terminator: "")
            }
            self.assertIsolated()
        }
    }

		// Guaranteed order 
		// The tasks are annotated to be on ExampleActor THEREFORE
		// The tasks must start and fully execute on that actor.
    func startTasksIsolatedWithAnnotations(run: Int)  {
        print("\nRun \(run) ", terminator: "")
        let x = Task { @ExampleActor in 
            await MainActor.run {
                print("a", terminator: "")
            }
        }
        let y = Task { @ExampleActor in 
            await MainActor.run {
                print("b", terminator: "")
            }
        }
        let z = Task { @ExampleActor in 
            await MainActor.run {
                print("c", terminator: "")
            }
        }
    }
 }
 
// From Main
 
let example = TaskExample()

print("Without Annotations -- any order")
for run in 0..<10 {
    await example.startTasksIsolated(run: run)
    
    try await Task.sleep(for: .seconds(1))
}
print("\n")

print("With self capture -- guaranteed order")
for run in 0..<10 {
    await example.startTasksIsolatedWithCapture(run: run)
    try await Task.sleep(for: .seconds(1))
}
print("\n")

print("With self capture -- but not guaranteed order")
for run in 0..<10 {
    await example.startTasksIsolatedWithSelfCaptureStartOnMain(run: run)
    try await Task.sleep(for: .seconds(1))
}
print("\n")

print("With Annotations -- guaranteed order")
for run in 0..<10 {
    await example.startTasksIsolatedWithAnnotations(run: run)
    try await Task.sleep(for: .seconds(1))
}
print("\n")
```

> Swift reserves the right to optimize the execution of tasks to avoid "unnecessary" isolation changes
> 

### 5. You need to have **NonisolatedNonSending turned on**

https://github.com/swiftlang/swift-evolution/blob/main/proposals/0461-async-function-isolation.md#nonisolatednonsending-functions

nonisolated synchronous functions always run on the caller's actor

nonisolated async functions run on the caller's actor by default ONLY if NonIsolatedNonSending method is turned on

```swift
nonisolated func exampleActorAsync() async {
        ExampleActor.assertIsolated()
        print("We're on the calling actor")
        let k = await Task { @MainActor in
            print("Some work off current actor")
            MainActor.assertIsolated()
            let x: () = try await Task.sleep(for: .seconds(1))
            
            return x
        }
        try? await Task.sleep(for: .seconds(1))
        ExampleActor.assertIsolated()
        print("We're still on the calling actor")
}
```

• **Task.immediate { ... }**

Attempts to get as far as it can in the given task closure (with the calling actor context), and then enqueues any remaining work.

```swift
func incrementStuff() {
    // Performs an enqueue and will execute task "later"
    Task { @MainActor in
        await incrementUsual() // Executes on MainActor
    }
    // At this point (in this specific example), `counterUsual` is still 0.
    // We did not "give up" the main actor executor, so the new Task could not execute yet.
    
    // Execute the task immediately on the calling context (!)
    Task.immediate { @MainActor in
        print("Immediate Increment")
        await incrementImmediate() // This executes on MainActor
        
        // Everything past here is handed off
        await incrementOther() // This executes on OtherActor
        await incrementImmediate()
        print("Completed task: \(Counter.counterImmediate)")
    }
    // At this point (in this specific cexample),
    MainActor.assumeIsolated {
        print(Counter.counterUsual) // no increment at this time
        print(Counter.counterImmediate) // one increment
    }
}

```