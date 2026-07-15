fileprivate enum Scenario: Int {
    // Shows how an actor method can be reentered while suspended at an await.
    case reentrantReservation

    // Keeps the critical reservation decision in a non-suspending actor operation.
    case nonSuspendingReservation
}

fileprivate let selectedScenarios: [Scenario] = [
    .reentrantReservation,
    .nonSuspendingReservation
]

if selectedScenarios.contains(.reentrantReservation) {
    await runReentrantReservationExample()
}

if selectedScenarios.contains(.nonSuspendingReservation) {
    await runNonSuspendingReservationExample()
}
