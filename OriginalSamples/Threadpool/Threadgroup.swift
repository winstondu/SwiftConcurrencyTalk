//
//  Threadgroup.swift
//  OriginalSamples
//
//  Created by Winston Du on 2/11/25.
//
import Foundation
 
fileprivate class ThreadGroupEntry {
    @objc func Entry() {
        let runloop = RunLoop.current
        runloop.add(NSMachPort(), forMode: .default)
        runloop.run()
    }
}

fileprivate class ActionWrapper: NSObject {
    let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    @objc func run() {
        self.closure()
    }
}

class ThreadGroup {
    let threads: [Thread]
    fileprivate let entry = ThreadGroupEntry()
    
    init(numThreads: Int = 10) {
        let entry = self.entry
        threads = Array<Int>.init(repeating: 0, count: numThreads).map { _ in
            let thread = Thread(target: entry, selector: #selector(ThreadGroupEntry.Entry), object: nil)
            thread.name = "Thread-\(UUID().uuidString)"
            thread.start()
            return thread
        }
    }
    
    var index = 0
    
    func getNextThread() -> Thread {
        index = (index + 1) % threads.count
        return threads[index]
    }
    
    func run(closure: @escaping () -> Void) {
        let thread = getNextThread()
        let action = ActionWrapper(closure: closure)
        action.perform(#selector(ActionWrapper.run), on: thread, with: nil, waitUntilDone: false)
    }
}

func runThreadGroup() {
    let pool = ThreadGroup()
    
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
