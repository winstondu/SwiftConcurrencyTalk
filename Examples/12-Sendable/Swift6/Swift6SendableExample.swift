actor Counter {
    private var value = 0

    func increment() {
        value += 1
    }

    func snapshot() -> Int {
        value
    }
}

func runSwift6SendableExample() async {
    let counter = Counter()

    await withTaskGroup(of: Void.self) { group in
        for _ in 1...100 {
            group.addTask {
                await counter.increment()
            }
        }
    }

    print("counter = \(await counter.snapshot())")
}
