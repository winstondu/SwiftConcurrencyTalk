fileprivate enum Scenario: Int {
    // A task group races useful work against a timeout and cooperatively cancels the loser.
    case timeoutCancellation
}

fileprivate let selectedScenarios: [Scenario] = [
    .timeoutCancellation
]

if selectedScenarios.contains(.timeoutCancellation) {
    await runTimeoutCancellationExample()
}
