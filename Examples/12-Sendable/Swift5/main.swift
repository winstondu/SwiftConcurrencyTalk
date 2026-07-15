fileprivate enum Scenario: Int {
    /// Swift 5 migration case that exposes a warning for sharing mutable class state across tasks.
    case swift5Sendable
}

fileprivate let selectedScenarios: [Scenario] = [
    .swift5Sendable
]

if selectedScenarios.contains(.swift5Sendable) {
    await runSwift5SendableExample()
}
