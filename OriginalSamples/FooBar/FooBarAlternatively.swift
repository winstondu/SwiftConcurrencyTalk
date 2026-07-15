//
//  FooBarAlternatively.swift
//  OriginalSamples
//
//  Created by Winston Du on 1/28/25.
//

import Foundation

class FooBar: FooBarInterface, @unchecked Sendable {
    
    let n: Int
    
    let condition = NSConditionImpl()
    
    var isFoo: Bool = true
    
    init(n: Int) {
        self.n = n
    }
    
    func foo() {
        for i in 0..<n {
            condition.lock()
            while !isFoo {
                condition.wait()
            }
            isFoo.toggle()
            
            print("foo\(i)")
            
            condition.signal()
            condition.unlock()
        }
    }
    
    func bar() {
        for i in 0..<n {
            condition.lock()
            while isFoo {
                condition.wait()
            }
            // bar time
            isFoo.toggle()
            
            print("bar\(i)")
            
            condition.signal()
            condition.unlock()
        }
        
    }
}

protocol FooBarInterface {
    func foo()
    
    func bar()
}


func runFooBar() {
    let foobar = FooBar(n: 10)
    
    DispatchQueue(label: "One").async {
        foobar.foo()
    }
    
    DispatchQueue(label:"Two").async {
        foobar.bar()
    }
}


// How NSCondition could be implemented
class NSConditionImpl {
    var conditionLock: NSLock = NSLock()
    
    var threadWaitLocks: [Thread: DispatchSemaphore] = [:]
    
    var waitingThreads: Set<Thread> = []
    
    func lock() {
        conditionLock.lock()
    }
    
    func unlock() {
        conditionLock.unlock()
    }
    
    func wait() {
        waitingThreads.insert(Thread.current)
        
        if threadWaitLocks[Thread.current] == nil {
            threadWaitLocks[Thread.current] = DispatchSemaphore(value: 0)
        }
        
        conditionLock.unlock()
        
        // Wait again -- this is now blocking
        threadWaitLocks[Thread.current]?.wait()
        
        // Reobtain lock.
        conditionLock.lock()
    }
    
    func signal() {
        guard let signalledThread = waitingThreads.first else {
            return
        }
        waitingThreads.remove(signalledThread)
        threadWaitLocks[signalledThread]?.signal()
    }
    
    func broadcast() {
        for signalledThread in waitingThreads {
            threadWaitLocks[signalledThread]?.signal()
        }
    }
}
