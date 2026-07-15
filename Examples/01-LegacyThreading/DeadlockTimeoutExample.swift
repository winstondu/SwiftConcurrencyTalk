import Foundation

func runDeadlockTimeoutExample() {
    print("")
    print("== Deadlock detected with timeout ==")

    let lockA = NSLock()
    let lockB = NSLock()
    let bothFinished = DispatchGroup()
    let worker1LockedA = DispatchSemaphore(value: 0)
    let worker2LockedB = DispatchSemaphore(value: 0)

    bothFinished.enter()
    DispatchQueue.global().async {
        lockA.lock()
        print("worker 1 locked A")
        worker1LockedA.signal()
        worker2LockedB.wait()
        print("worker 1 waiting for B")
        lockB.lock()
        lockB.unlock()
        lockA.unlock()
        bothFinished.leave()
    }

    bothFinished.enter()
    DispatchQueue.global().async {
        worker1LockedA.wait()
        lockB.lock()
        print("worker 2 locked B")
        worker2LockedB.signal()
        Thread.sleep(forTimeInterval: 0.02)
        print("worker 2 waiting for A")
        lockA.lock()
        lockA.unlock()
        lockB.unlock()
        bothFinished.leave()
    }

    let result = bothFinished.wait(timeout: .now() + 0.3)
    switch result {
    case .success:
        print("unexpectedly completed")
    case .timedOut:
        print("timeout reached; the program keeps control instead of hanging forever")
    }
}
