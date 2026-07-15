final class Counter {
    var value = 0
}

func runSwift5SendableExample() async {
    let counter = Counter()

    await withTaskGroup(of: Void.self) { group in
        for _ in 1...100 {
            group.addTask {
                counter.value += 1
            }
        }
    }

    print("counter = \(counter.value)")
}
