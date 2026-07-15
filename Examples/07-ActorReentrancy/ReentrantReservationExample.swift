import Foundation

actor ReentrantReservationInventory {
    private var availableTickets = 1

    func reserveWithSuspension(customer: String) async -> Bool {
        print("\(customer) sees \(availableTickets) ticket(s) before awaiting")

        guard availableTickets > 0 else {
            return false
        }

        try? await Task.sleep(for: .milliseconds(200))

        if availableTickets > 0 {
            availableTickets -= 1
            print("\(customer) reserved a ticket after the await")
            return true
        } else {
            print("\(customer) resumed, but the ticket was already taken")
            return false
        }
    }

    func remainingTickets() -> Int {
        availableTickets
    }
}

func runReentrantReservationExample() async {
    print("Reentrant reservation:")
    let reentrantInventory = ReentrantReservationInventory()

    async let first = reentrantInventory.reserveWithSuspension(customer: "Asha")
    async let second = reentrantInventory.reserveWithSuspension(customer: "Ben")

    let reentrantResults = await [first, second]
    print("Results:", reentrantResults)
    print("Remaining tickets:", await reentrantInventory.remainingTickets())
}
