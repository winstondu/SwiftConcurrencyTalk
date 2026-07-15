fileprivate enum Scenario: Int {
    /// Swift 5 baseline where `nonisolated async` moves helper work out of `@MainActor` state.
    case swift5Scheduling
}

fileprivate let selectedScenarios: [Scenario] = [
    .swift5Scheduling
]

if selectedScenarios.contains(.swift5Scheduling) {
    await runSwift5SchedulingExample()
}
