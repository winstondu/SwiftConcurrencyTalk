fileprivate enum Scenario: Int {
    /// Swift 6-safe rewrite where shared mutable state is protected by actor isolation.
    case swift6Sendable
}

fileprivate let selectedScenarios: [Scenario] = [
    .swift6Sendable
]

if selectedScenarios.contains(.swift6Sendable) {
    await runSwift6SendableExample()
}
