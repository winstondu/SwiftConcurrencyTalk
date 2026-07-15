//
//  main.swift
//  OriginalSamples
//
//  Created by Winston Du on 1/14/25.
//

import Foundation

enum DemoError: Error {
    case boom
}

func demo() async {
    print("before group")

    await withThrowingTaskGroup(of: Void.self) { group in
        group.addTask {
            try await Task.sleep(nanoseconds: 600_000_000)
            print("A finished normally")
        }

        group.addTask {
            try await Task.sleep(nanoseconds: 200_000_000)
            print("B throws")
            throw DemoError.boom
        }

        print("returning normally from group body")
        return
        // Important: we do NOT call `try await group.next()`.
        // So B's error is never propagated out of the group body.
    }

    print("after group")
}

await demo()
