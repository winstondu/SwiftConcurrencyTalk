//
//  SpecialActor.swift
//  OriginalSamples
//
//  Created by Winston Du on 1/28/25.
//
import Foundation

final class CustomExecutor: SerialExecutor {
    private let queue: DispatchQueue

    init(label: String) {
        self.queue = DispatchQueue(label: label)
    }

    func enqueue(_ job: consuming ExecutorJob) {
        let unownedJob = UnownedJob(job)
        queue.async {
            unownedJob.runSynchronously(on: self.asUnownedSerialExecutor())
        }
    }

    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

@globalActor
actor OtherActor: GlobalActor {
    static let shared = OtherActor()
    
    // This is private.
    private static let executor = CustomExecutor(label: "OK")

    // This needs to exist
    nonisolated var unownedExecutor: UnownedSerialExecutor {
        Self.executor.asUnownedSerialExecutor()
    }
}


// Test

func generateTaskOnSpecialExecutor() -> Task<Void, Never> {
    let task = Task { @OtherActor in
        print(Thread.current.isMainThread)
    }
    return task
}
