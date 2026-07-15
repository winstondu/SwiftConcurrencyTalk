fileprivate enum Scenario: Int {
    // Awaits independent async operations one after another.
    case sequentialAsyncCalls
    // Starts a child task and later awaits its value.
    case taskValue
}

fileprivate let selectedScenarios: [Scenario] = [
    .sequentialAsyncCalls,
    .taskValue,
]

print("Task basics examples")
if selectedScenarios.contains(.sequentialAsyncCalls) {
    await runSequentialAsyncCallsExample()
}
if selectedScenarios.contains(.taskValue) {
    await runTaskValueExample()
}
print("")
print("Done")
