fileprivate enum Scenario: Int {
    /// Swift 6 version that uses `@concurrent nonisolated` to make off-actor scheduling explicit.
    case swift6Scheduling
}

fileprivate let selectedScenarios: [Scenario] = [
    .swift6Scheduling
]

if selectedScenarios.contains(.swift6Scheduling) {
    await runSwift6SchedulingExample()
}
