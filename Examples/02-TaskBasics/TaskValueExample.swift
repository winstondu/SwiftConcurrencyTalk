import Foundation

func runTaskValueExample() async {
    print("")
    print("== Task value ==")

    let task = Task {
        await pause(30)
        return "child task result"
    }

    print(await task.value)
}

private func pause(_ milliseconds: UInt64) async {
    try? await Task.sleep(nanoseconds: milliseconds * 1_000_000)
}
