import Foundation

private protocol LegacyFooBarInterface {
    func foo()
    func bar()
}

// Safety invariant: callers must hold conditionLock while reading or changing
// waitingThreads and threadWaitLocks.
private final class LegacyCondition: @unchecked Sendable {
    private let conditionLock = NSLock()
    private var threadWaitLocks: [Thread: DispatchSemaphore] = [:]
    private var waitingThreads: [Thread] = []

    func lock() {
        conditionLock.lock()
    }

    func unlock() {
        conditionLock.unlock()
    }

    func wait() {
        let currentThread = Thread.current
        waitingThreads.append(currentThread)

        if threadWaitLocks[currentThread] == nil {
            threadWaitLocks[currentThread] = DispatchSemaphore(value: 0)
        }

        let semaphore = threadWaitLocks[currentThread]
        conditionLock.unlock()
        semaphore?.wait()
        conditionLock.lock()
    }

    func signal() {
        guard !waitingThreads.isEmpty else {
            return
        }

        let signalledThread = waitingThreads.removeFirst()
        threadWaitLocks[signalledThread]?.signal()
    }
}

private final class FooBarCondition: LegacyFooBarInterface, @unchecked Sendable {
    private let n: Int
    private let condition = LegacyCondition()
    private var isFooTurn = true

    init(n: Int) {
        self.n = n
    }

    func foo() {
        for index in 0..<n {
            condition.lock()
            while !isFooTurn {
                condition.wait()
            }

            print("foo\(index)")
            isFooTurn = false
            condition.signal()
            condition.unlock()
        }
    }

    func bar() {
        for index in 0..<n {
            condition.lock()
            while isFooTurn {
                condition.wait()
            }

            print("bar\(index)")
            isFooTurn = true
            condition.signal()
            condition.unlock()
        }
    }
}

func runFooBarConditionExample() {
    print("")
    print("== Foo/Bar with custom condition ==")

    let fooBar = FooBarCondition(n: 3)
    let finished = DispatchGroup()

    finished.enter()
    DispatchQueue(label: "FooBar.condition.foo").async {
        fooBar.foo()
        finished.leave()
    }

    finished.enter()
    DispatchQueue(label: "FooBar.condition.bar").async {
        fooBar.bar()
        finished.leave()
    }

    finished.wait()
}
