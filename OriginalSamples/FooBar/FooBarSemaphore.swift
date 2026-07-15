//
//  FooBarSemaphore.swift
//  OriginalSamples
//
//  Created by Winston Du on 2/11/25.
//

import Foundation

class FooBarSemaphore: @unchecked Sendable {
    let n: Int
    let fooSemaphore = DispatchSemaphore(value: 0)
    let barSemaphore = DispatchSemaphore(value: 0)
    
    init(n: Int) {
        self.n = n
        fooSemaphore.signal()
    }
    
    func foo() {
        for _ in 0..<n {
            fooSemaphore.wait()
            print("Foo")
            barSemaphore.signal()
        }
    }
    
    func bar() {
        for _ in 0..<n {
            barSemaphore.wait()
            print("Bar")
            fooSemaphore.signal()
        }
    }
}

func runFooBarSemaphore() {
    let foobar = FooBarSemaphore(n: 10)
    Task {
        foobar.foo()
    }
    
    Task {
        foobar.bar()
    }
//    DispatchQueue(label: "One").async {
//        foobar.foo()
//    }
//    
//    DispatchQueue(label:"Two").async {
//        foobar.bar()
//    }
}
