fileprivate enum Scenario: Int {
    /// Legacy behavior where a non-Sendable object is passed to a `nonisolated async` helper.
    case legacyNonisolatedNonsending
}

fileprivate let selectedScenarios: [Scenario] = [
    .legacyNonisolatedNonsending
]

if selectedScenarios.contains(.legacyNonisolatedNonsending) {
    await runLegacyNonisolatedNonsendingExample()
}
