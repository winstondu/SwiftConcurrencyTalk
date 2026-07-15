fileprivate enum Scenario: Int {
    // Orders submitted work on a private DispatchQueue.
    case serialQueue
    // Uses an NSLock to guard shared mutable state across concurrent jobs.
    case lockProtectedCounter
    // Keeps dedicated Thread instances alive with run loops for scheduled work.
    case runLoopThreadPool
    // Schedules work across a small legacy thread pool in round-robin order.
    case threadGroupRoundRobin
    // Coordinates alternating work with a custom condition-style primitive.
    case fooBarCondition
    // Coordinates alternating work with paired DispatchSemaphore instances.
    case fooBarSemaphore
    // Demonstrates using a timeout to keep a deadlock from hanging the process.
    case deadlockTimeout
}

fileprivate let selectedScenarios: [Scenario] = [
    .serialQueue,
    .lockProtectedCounter,
    .runLoopThreadPool,
    .threadGroupRoundRobin,
    .fooBarCondition,
    .fooBarSemaphore,
    .deadlockTimeout,
]

print("Legacy threading examples")
if selectedScenarios.contains(.serialQueue) {
    runSerialQueueExample()
}
if selectedScenarios.contains(.lockProtectedCounter) {
    runLockProtectedCounterExample()
}
if selectedScenarios.contains(.runLoopThreadPool) {
    runRunLoopThreadPoolExample()
}
if selectedScenarios.contains(.threadGroupRoundRobin) {
    runThreadGroupRoundRobinExample()
}
if selectedScenarios.contains(.fooBarCondition) {
    runFooBarConditionExample()
}
if selectedScenarios.contains(.fooBarSemaphore) {
    runFooBarSemaphoreExample()
}
if selectedScenarios.contains(.deadlockTimeout) {
    runDeadlockTimeoutExample()
}
print("")
print("Done")
