//
//  Threadpool.swift
//  OriginalSamples
//
//  Created by Winston Du on 2/4/25.
//
import Foundation

// This encapsulates thread entry logic.
private final class ThreadTarget: NSObject {
    @objc fileprivate func threadEntryPoint() {
        let runLoop = RunLoop.current
        // Add the dummy input to keep the run-loop going
        runLoop.add(NSMachPort(), forMode: RunLoop.Mode.default)
        
        runLoop.run()
    }
}

// This just wraps a closure in an NSObject
private final class Action: NSObject {
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    @objc func performAction() {
        action()
    }
}

class Threadpool {
    private var threads: [Thread] = []
    private let target: ThreadTarget
    
    private var nextThreadToSchedule = 0
    private var lock = NSLock()

    init(threadcount: Int = 10) {
        self.target = ThreadTarget()
        let uuid = UUID().uuidString
        for i in 0..<threadcount {
            let thread = Thread(target: target,
                                 selector: #selector(ThreadTarget.threadEntryPoint),
                                 object: nil)
            thread.name = "Threadpool-\(uuid)-\(i)"
            threads.append(thread)
            thread.start()
        }
    }
    
    private func getNextThread() -> Thread {
        lock.lock()
        defer {
            lock.unlock()
        }
        let nextThread = threads[nextThreadToSchedule]
        nextThreadToSchedule = (nextThreadToSchedule + 1) % threads.count
        return nextThread
    }
    
    func run(_ closure: @escaping () -> Void) {
        let thread = getNextThread()
        let action = Action(action: closure)
        action.perform(#selector(Action.performAction),
                                on: thread,
                                with: nil,
                                waitUntilDone: false,
                                modes: [RunLoop.Mode.default.rawValue])
    }
}

func runThreadpool() {
    let pool = Threadpool()
    
    pool.run {
        print("Running on \(Thread.current.name)")
    }
    pool.run {
        print("Going Running on \(Thread.current.name)")
    }
    pool.run {
        print("Running on \(Thread.current.name)")
    }
    pool.run {
        print("Running on \(Thread.current.name)")
    }
    pool.run {
        print("Running on \(Thread.current.name)")
    }
    pool.run {
        Thread.sleep(forTimeInterval: 1)
        print("Late Running on \(Thread.current.name)")
    }
    pool.run {
        print("Running on \(Thread.current.name)")
    }
    pool.run {
        print("Running on \(Thread.current.name)")
    }
    pool.run {
        print("Running on \(Thread.current.name)")
    }
    pool.run {
        print("Running on \(Thread.current.name)")
    }


    Thread.sleep(forTimeInterval: 10)
}
