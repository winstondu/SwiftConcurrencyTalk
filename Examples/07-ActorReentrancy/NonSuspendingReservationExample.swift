import Foundation

actor ImmediateReservationInventory {
    private var availableTickets = 1

    func reserveWithoutSuspension(customer: String) -> Bool {
        guard availableTickets > 0 else {
            print("\(customer) found no ticket available")
            return false
        }

        availableTickets -= 1
        print("\(customer) reserved immediately")
        return true
    }

    func remainingTickets() -> Int {
        availableTickets
    }
}

func runNonSuspendingReservationExample() async {
    print("\nNon-suspending reservation:")
    let guardedInventory = ImmediateReservationInventory()

    async let third = guardedInventory.reserveWithoutSuspension(customer: "Cora")
    async let fourth = guardedInventory.reserveWithoutSuspension(customer: "Dev")

    let guardedResults = await [third, fourth]
    print("Results:", guardedResults)
    print("Remaining tickets:", await guardedInventory.remainingTickets())
}
