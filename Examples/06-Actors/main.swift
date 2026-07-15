fileprivate enum Scenario: Int {
    // Concurrent deposits and withdrawals are serialized through one actor-isolated account.
    case bankAccountActor
}

fileprivate let selectedScenarios: [Scenario] = [
    .bankAccountActor
]

if selectedScenarios.contains(.bankAccountActor) {
    await runBankAccountActorExample()
}
