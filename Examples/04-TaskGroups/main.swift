fileprivate enum Scenario: Int {
    // Uses a task group when the amount of parallel work comes from runtime data.
    case dynamicParallelWork
    // Caps concurrent simulated requests while continuing to feed the group.
    case boundedRequestLoading
}

fileprivate let selectedScenarios: [Scenario] = [
    .dynamicParallelWork,
    .boundedRequestLoading,
]

print("Task group examples")

if selectedScenarios.contains(.dynamicParallelWork) {
    await runDynamicParallelWorkExample()
}
if selectedScenarios.contains(.boundedRequestLoading) {
    await runBoundedRequestLoadingExample()
}

print("")
print("Done")
