# Structured Concurrency / Swift Concurrency:

https://stackoverflow.com/questions/73958676/can-an-actor-method-be-interacted-concurrently

Intro:

- Explore Structured Concurrency in Swift (WWDC 21)
- Beyond the basics of Structured Concurrency (WWDC 23)

[Structured Concurrency Gotchas](https://www.notion.so/Structured-Concurrency-Gotchas-27818c730b7d805197c9cec5aadf7c01?pvs=21)

**Tasks:**

- `Task`s normally start running straight away on the thread on which they are defined. This means if they are started on the main thread, they should run on the main thread.
- `await` functions act as a suspension point, where work might leave the  actor and execute elsewhere before coming back
- `Task.detached` passes the work to the global executor to be scheduled on any available global thread.

From: https://forums.swift.org/t/should-task-groups-inherit-actor/57547?utm_source=chatgpt.com

**Notice — Only unstructured Tasks inherit callers actor**

![image.png](Structured%20Concurrency%20Swift%20Concurrency/image.png)

**`Task.immediate`**

From: https://github.com/swiftlang/swift-evolution/blob/main/proposals/0472-task-start-synchronously-on-caller-context.md

> By using an immediate task the runtime is able to notice that the requested, and current, executor are actually the same
> 

If you are on the executor its supposed to run in, run immediately. 

Otherwise, enqueue onto the appropriate actor’s executor 

**Async Let (Do static list of tasks in parallel)**

```swift
public func fetchThumbnails() async throws -> [Thumbnail] {
    async let t1 = try fetchThumbnail(for: "100")
    async let t2 = try fetchThumbnail(for: "101")

    return try await [t1, t2] // Execute both in parallel
}
```

**Task Groups (Do a dynamic set of tasks in parallel)**

```swift
let photoURLs: [URL] = [] // some url list
let images = try await withThrowingTaskGroup(of: UIImage.self, returning: [UIImage].self) { taskGroup in
    for photoURL in photoURLs {
        taskGroup.addTask { try await downloadPhoto(url: photoURL) }
    }

    var images = [UIImage]()

    /// Note the use of `next()`:
    while let downloadImage = try await taskGroup.next() {
        images.append(downloadImage)
    }
    // Alternatively:
    // for try await image in group {
		//    images.append(image)
		// }
    
    return images
}
```

Important!

https://forums.swift.org/t/accepted-with-modifications-se-0304-structured-concurrency/51850/9

> If you return normally from the body, all remaining tasks are awaited, and their results (whether normal or error) are discarded with no effect on the other tasks. Therefore we have a discrepancy between the proposal and its implementation.
> 

Tasks always run to completion:

From: https://developer.apple.com/documentation/swift/taskgroup

> even though the code returns the first collected integer from all actions added to the task group, the task group *always*, automatically, waits for the completion of all the resulting tasks.
> 
> 
> You can use `group.cancelAll()` to signal cancellation to the remaining in-progress tasks, however this doesn’t interrupt their execution automatically. Rather, the child tasks need to cooperatively react to the cancellation, and return early if that’s possible.
> 

Parent tasks that throw **cancels all** child tasks

From: https://github.com/swiftlang/swift-evolution/blob/main/proposals/0304-structured-concurrency.md

> Cancellation can also trigger automatically, for example when a parent task throws an error out of a scope with unawaited child tasks.
> 

Gotchas:

— Before 

https://forums.swift.org/t/task-is-order-of-task-execution-deterministic/51553/41

— After SE 431 https://github.com/swiftlang/swift-evolution/blob/main/proposals/0431-isolated-any-functions.md

This proposal modifies all of these APIs so that the task function has `@isolated(any)` function type. These APIs now all synchronously enqueue the new task directly on the appropriate executor for the task function's dynamic isolation.

Good Resource to read: https://www.massicotte.org/concurrency-swift-6-se-0431

**Before** SE 431, creating a task ALWAYS meant a double hop — start the task on the global concurrent executor, and then enqueue to the MainActor. 

**After:**

Swift will always enqueue a task function on the appropriate executor for its **formal dynamic isolation** (the isolation the closure will run in) unless:

- The Task is non-isolated (i.e. via a detached Task) — in this case there is no
- It comes from a closure expression that is only ***implicitly* isolated** to an actor.
    - **Implicitly isolated** means the task closure has neither of the following:
        - a global actor attribute (e.g. `@MainActor`)
        - an explicit `isolated` capture — (Not relevant as of Swift 6.2)
    - Note: This implicitly isolated situation can currently only happen with `Task {}`.

**NonisolatedNonSending Flag:**

— **BEFORE**: nonisolated async methods do not inherit the caller’s actor.

— **AFTER** (with Flag): nonisolated async methods inherit from the caller’s actor, just like nonisolated sync methods. 

- If you want the nonisolated async methods to be run on the global executor, use `@concurrent`
    - Note: `@concurrent` always implicitly makes the method nonisolated. `@concurrent` can only be applied to nonisolated functions.
    
    https://www.avanderlee.com/concurrency/concurrent-explained-with-code-examples/
    

**Common Mistake**

This does **not** await the task’s completion. It merely creates it.

```jsx
await Task { @MainActor in
    updateUI()
}
```

You must await task.value or use MainActor.run.

[**Define a different global actor**](https://www.notion.so/Define-a-different-global-actor-17d18c730b7d8048a6bdcf6f0fd6661d?pvs=21)

**Migrating to Structured Concurrency:**

[https://www.andyibanez.com/posts/](https://www.andyibanez.com/posts/)

— Special case:

https://forums.swift.org/t/automatically-cancelling-continuations/72960/9?utm_source=chatgpt.com

**Actors:**

See: https://developer.apple.com/videos/play/wwdc2021/10133

TLDR: Actors ensure 

- Their **synchronous** methods and property accesses are **isolated** and serialized
    - **In other words,** its as if you wrapped everything in `queue.sync` for a SerialDispatchQueue!
- **However,** be aware that the **async method** of actors will introduce **actor re-entrancy**
    - When an actor method suspends, the actor **CAN** process other messages.
    
    ```swift
    actor ImageDownloader {
        private var cache: [URL: Image] = [:]
    
        func image(from url: URL) async throws -> Image? {
    		    // Part 1 -- this all runs isolated until the await.
            if let cached = cache[url] {
                return cached
            }
    
    				// This is a suspension point. 
    				// On suspend, the actor can do other stuff. 
            let image = try await downloadImage(from: url)
            // Part 2 -- this all runs isolated until the return.
    
            // Potential bug: `cache` may have changed, 
            cache[url] = image
            return image
        }
    }
    ```
    
- To solve this generally, use an asyncLock to have critical sections in your actor’s async method
    - https://github.com/ivalx1s/swift-stdlibplus/blob/main/Sources/Async/AsyncLock.swift
    
    ```swift
    actor DBConnection {
    	private let lock = AsyncLock()
    	func performTransaction() async {
    	  // without the lock, other actor methods could execute between await points
    		await lock.withLock {
    		  // Multiple database operations must complete together
    			await operation1()
    			await operation2()
    			// No others start until both operation1 & operation2 complete.
    		}
    	}
    }
    ```
    

[https://www.swiftwithvincent.com/blog/discover-how-main-actor-works-in-swift#:~:text=%40MainActor can be used in,switches to the main thread](https://www.swiftwithvincent.com/blog/discover-how-main-actor-works-in-swift#:~:text=%40MainActor%20can%20be%20used%20in,switches%20to%20the%20main%20thread).

**Async with Combine**

https://www.swiftbysundell.com/articles/async-sequences-streams-and-combine/

Tasks:

Use `withTaskCancellationHandler` on any async method 

**Sendable**

From: https://forums.swift.org/t/are-sending-and-sendable-same-or-related/77071/3

“a `sending` parameter is either a `Sendable` or if it is a non-Sendable, then it is not allowed (or assumed that it is not allowed) to be modified by both the threads”

From: https://github.com/swiftlang/swift-evolution/blob/main/proposals/0302-concurrent-value-and-concurrent-closures.md

“Swift has hard coded conformances for tuples to specific protocols, and this should be extended to Sendable, when the tuple’s elements all conform to Sendable.”

Automatically cancelling continuations

https://forums.swift.org/t/automatically-cancelling-continuations/72960/9?utm_source=chatgpt.com

https://developer.apple.com/videos/play/wwdc2022/110351/