//
//  Deadlock.swift
//  OriginalSamples
//
//  Created by Winston Du on 1/28/25.
//

import Foundation

let lockA = NSLock()
let lockB = NSLock()

func initiateDeadlock() {
    DispatchQueue(label: "One Element").async {
        print("Task 1 Begin")
        
        lockA.lock()
        
        Thread.sleep(forTimeInterval: 1.0)
        
        lockB.lock() // Here, we need to acquire lockB before unlocking lock A
        
        lockA.unlock()
        
        lockB.unlock()
        
        print("Task 1 complete")
    }

    DispatchQueue(label: "Task 2").async {
        print("Task 2 Begin")

        lockB.lock()

        Thread.sleep(forTimeInterval: 1.0)

        lockA.lock() // This is awaiting on lockA to be released, but

        lockB.unlock()

        lockA.unlock()

        print("Task 2 complete")
    }

    Thread.sleep(forTimeInterval: 5.0)

    print("Finishing -- Notice Task 1 & Task 2 did not occur")
}
