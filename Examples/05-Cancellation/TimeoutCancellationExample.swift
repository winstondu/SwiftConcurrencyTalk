import Foundation

enum ExampleError: Error {
    case timedOut
}

func cooperativeWorker() async throws -> Int {
    var completedSteps = 0

    for step in 1...10 {
        try Task.checkCancellation()
        try await Task.sleep(nanoseconds: 40_000_000)
        completedSteps = step
        print("worker completed step \(step)")
    }

    return completedSteps
}

func runWithTimeout(milliseconds: UInt64) async throws -> Int {
    try await withThrowingTaskGroup(of: Int.self) { group in
        group.addTask {
            try await cooperativeWorker()
        }

        group.addTask {
            try await Task.sleep(nanoseconds: milliseconds * 1_000_000)
            throw ExampleError.timedOut
        }

        guard let firstResult = try await group.next() else {
            throw CancellationError()
        }

        group.cancelAll()
        return firstResult
    }
}

func runTimeoutCancellationExample() async {
    print("Cancellation examples")

    print("")
    print("== Timeout cancels slower work ==")
    do {
        let steps = try await runWithTimeout(milliseconds: 130)
        print("worker finished all \(steps) steps")
    } catch ExampleError.timedOut {
        print("timeout won; remaining work was cancelled")
    } catch is CancellationError {
        print("work noticed cancellation")
    } catch {
        print("unexpected error: \(error)")
    }

    print("")
    print("Done")
}
