@MainActor
final class ExportViewModel {
    private var status = "idle"

    func export() async {
        status = "preparing"
        let report = await renderReport(id: 42)
        status = "finished"
        print("\(status): \(report)")
    }

    @concurrent nonisolated func renderReport(id: Int) async -> String {
        var checksum = 0
        for n in 1...50_000 {
            checksum &+= n ^ id
        }
        return "report-\(id) checksum=\(checksum)"
    }
}

func runSwift6SchedulingExample() async {
    await ExportViewModel().export()
}
