final class Scratchpad {
    var entries: [String] = []

    func append(_ value: String) {
        entries.append(value)
    }
}

@MainActor
final class ScreenModel {
    private let pad = Scratchpad()

    func run() async {
        pad.append("created on MainActor")
        await summarize(pad)
        print(pad.entries.joined(separator: " | "))
    }

    nonisolated func summarize(_ pad: Scratchpad) async {
        pad.append("used by nonisolated async helper")
    }
}

func runLegacyNonisolatedNonsendingExample() async {
    await ScreenModel().run()
}
