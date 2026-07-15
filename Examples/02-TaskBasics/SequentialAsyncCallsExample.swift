import Foundation

func runSequentialAsyncCallsExample() async {
    print("")
    print("== Sequential async calls ==")

    let name = await fetchProfileName()
    let score = await fetchProfileScore()
    print("profile: \(name), score: \(score)")
}

private func fetchProfileName() async -> String {
    await pause(60)
    return "Avery"
}

private func fetchProfileScore() async -> Int {
    await pause(40)
    return 42
}

private func pause(_ milliseconds: UInt64) async {
    try? await Task.sleep(nanoseconds: milliseconds * 1_000_000)
}
