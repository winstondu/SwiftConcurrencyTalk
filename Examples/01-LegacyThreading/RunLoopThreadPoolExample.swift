import Foundation

private final class LegacyRunLoopAction: NSObject {
    private let action: () -> Void

    init(_ action: @escaping () -> Void) {
        self.action = action
    }

    @objc func run() {
        action()
    }
}

private final class LegacyRunLoopWorker: NSObject {
    private let lock = NSLock()
    private var shouldStop = false

    @objc func threadEntryPoint() {
        let runLoop = RunLoop.current
        runLoop.add(NSMachPort(), forMode: .default)

        while !isStopped {
            runLoop.run(mode: .default, before: Date(timeIntervalSinceNow: 0.05))
        }
    }

    private var isStopped: Bool {
        lock.lock()
        let result = shouldStop
        lock.unlock()
        return result
    }

    func stop() {
        lock.lock()
        shouldStop = true
        lock.unlock()
    }
}

private final class LegacyRunLoopThreadPool {
    private let worker = LegacyRunLoopWorker()
    private let lock = NSLock()
    private var nextThreadToSchedule = 0
    private var threads: [Thread] = []

    init(threadCount: Int) {
        for index in 0..<threadCount {
            let thread = Thread(
                target: worker,
                selector: #selector(LegacyRunLoopWorker.threadEntryPoint),
                object: nil
            )
            thread.name = "Threadpool-\(index)"
            threads.append(thread)
            thread.start()
        }
    }

    func run(_ closure: @escaping () -> Void) {
        let thread = getNextThread()
        let action = LegacyRunLoopAction(closure)
        action.perform(
            #selector(LegacyRunLoopAction.run),
            on: thread,
            with: nil,
            waitUntilDone: false,
            modes: [RunLoop.Mode.default.rawValue]
        )
    }

    func stop() {
        worker.stop()
        for thread in threads {
            LegacyRunLoopAction {}.perform(
                #selector(LegacyRunLoopAction.run),
                on: thread,
                with: nil,
                waitUntilDone: false,
                modes: [RunLoop.Mode.default.rawValue]
            )
        }
    }

    private func getNextThread() -> Thread {
        lock.lock()
        let thread = threads[nextThreadToSchedule]
        nextThreadToSchedule = (nextThreadToSchedule + 1) % threads.count
        lock.unlock()
        return thread
    }
}

private final class LegacyThreadGroup {
    private let pool: LegacyRunLoopThreadPool

    init(numThreads: Int) {
        pool = LegacyRunLoopThreadPool(threadCount: numThreads)
    }

    func run(_ closure: @escaping () -> Void) {
        pool.run(closure)
    }

    func stop() {
        pool.stop()
    }
}

func runRunLoopThreadPoolExample() {
    print("")
    print("== RunLoop-backed Thread pool ==")

    let pool = LegacyRunLoopThreadPool(threadCount: 3)
    let group = DispatchGroup()

    for job in 1...6 {
        group.enter()
        pool.run {
            print("pool job \(job) on \(Thread.current.name ?? "unnamed")")
            group.leave()
        }
    }

    group.wait()
    pool.stop()
}

func runThreadGroupRoundRobinExample() {
    print("")
    print("== ThreadGroup-style round robin ==")

    let groupPool = LegacyThreadGroup(numThreads: 2)
    let finished = DispatchGroup()

    for job in 1...4 {
        finished.enter()
        groupPool.run {
            print("thread group job \(job) on \(Thread.current.name ?? "unnamed")")
            finished.leave()
        }
    }

    finished.wait()
    groupPool.stop()
}
