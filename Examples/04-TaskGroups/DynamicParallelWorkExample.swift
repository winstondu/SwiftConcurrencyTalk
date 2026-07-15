import Foundation

struct WorkItem: Sendable {
    let id: Int
    let delayMilliseconds: UInt64
}

func runDynamicParallelWorkExample() async {
    print("")
    print("== Dynamic parallel work ==")

    let items = [
        WorkItem(id: 1, delayMilliseconds: 90),
        WorkItem(id: 2, delayMilliseconds: 30),
        WorkItem(id: 3, delayMilliseconds: 60)
    ]

    let orderedResults = await processAll(items)

    print("")
    print("== Results sorted for deterministic output ==")
    for result in orderedResults {
        print(result)
    }
}

private func processAll(_ items: [WorkItem]) async -> [String] {
    await withTaskGroup(of: (Int, String).self) { group in
        for item in items {
            group.addTask {
                let message = await process(item)
                return (item.id, message)
            }
        }

        var results: [(Int, String)] = []
        for await result in group {
            print("received result for item \(result.0)")
            results.append(result)
        }

        return results
            .sorted { left, right in left.0 < right.0 }
            .map { _, message in message }
    }
}

private func process(_ item: WorkItem) async -> String {
    try? await Task.sleep(nanoseconds: item.delayMilliseconds * 1_000_000)
    return "item \(item.id) finished after \(item.delayMilliseconds) ms"
}
