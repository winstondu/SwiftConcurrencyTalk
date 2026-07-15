fileprivate enum Scenario: Int {
    /// Modern behavior where plain `nonisolated async` inherits the caller's isolation by default.
    case modernNonisolatedNonsending
}

fileprivate let selectedScenarios: [Scenario] = [
    .modernNonisolatedNonsending
]

if selectedScenarios.contains(.modernNonisolatedNonsending) {
    await runModernNonisolatedNonsendingExample()
}
