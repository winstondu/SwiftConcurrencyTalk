import Foundation

// Safety invariant: every access to mutable state goes through this private lock.
final class LockedCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var total = 0
    private var snapshots: [Int] = []

    func increment() {
        lock.lock()
        total += 1
        snapshots.append(total)
        lock.unlock()
    }

    func report() -> (snapshots: [Int], total: Int) {
        lock.lock()
        let result = (snapshots, total)
        lock.unlock()
        return result
    }
}

func runLockProtectedCounterExample() {
    print("")
    print("== NSLock protects shared state ==")

    let queue = DispatchQueue(label: "example.concurrent", attributes: .concurrent)
    let group = DispatchGroup()
    let counter = LockedCounter()

    for _ in 1...5 {
        group.enter()
        queue.async {
            counter.increment()
            group.leave()
        }
    }

    group.wait()
    let (snapshots, total) = counter.report()
    for snapshot in snapshots.sorted() {
        print("counter reached \(snapshot)")
    }
    print("final counter: \(total)")
}
