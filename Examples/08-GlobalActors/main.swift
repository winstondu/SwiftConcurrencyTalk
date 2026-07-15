fileprivate enum Scenario: Int {
    // Uses a custom global actor to serialize audit logging across concurrent order work.
    case globalActorAuditLog

    // Runs global-actor-isolated work on an explicitly supplied serial executor.
    case customExecutorOtherActor
}

fileprivate let selectedScenarios: [Scenario] = [
    .globalActorAuditLog,
    .customExecutorOtherActor,
]

if selectedScenarios.contains(.globalActorAuditLog) {
    await runGlobalActorAuditLogExample()
}

if selectedScenarios.contains(.customExecutorOtherActor) {
    await runCustomExecutorOtherActorExample()
}
