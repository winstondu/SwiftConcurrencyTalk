import Foundation

func runFixedParallelWorkExample() async {
    print("")
    print("== Fixed parallel work ==")

    let dashboard = await buildDashboard()
    for line in dashboard {
        print(line)
    }
}

private func buildDashboard() async -> [String] {
    async let user = loadUser()
    async let settings = loadSettings()
    async let inbox = loadInboxCount()

    return await [user, settings, inbox]
}

private func loadUser() async -> String {
    await pause(80)
    return "user=Avery"
}

private func loadSettings() async -> String {
    await pause(40)
    return "theme=dark"
}

private func loadInboxCount() async -> String {
    await pause(20)
    return "inbox=3"
}

private func pause(_ milliseconds: UInt64) async {
    try? await Task.sleep(nanoseconds: milliseconds * 1_000_000)
}
