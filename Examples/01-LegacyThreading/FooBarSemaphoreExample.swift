import Foundation

private final class FooBarSemaphoreExample: @unchecked Sendable {
    private let n: Int
    private let fooSemaphore = DispatchSemaphore(value: 1)
    private let barSemaphore = DispatchSemaphore(value: 0)

    init(n: Int) {
        self.n = n
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

func runFooBarSemaphoreExample() {
    print("")
    print("== Foo/Bar with semaphores ==")

    let fooBar = FooBarSemaphoreExample(n: 3)
    let finished = DispatchGroup()

    finished.enter()
    DispatchQueue(label: "FooBar.semaphore.foo").async {
        fooBar.foo()
        finished.leave()
    }

    finished.enter()
    DispatchQueue(label: "FooBar.semaphore.bar").async {
        fooBar.bar()
        finished.leave()
    }

    finished.wait()
}
