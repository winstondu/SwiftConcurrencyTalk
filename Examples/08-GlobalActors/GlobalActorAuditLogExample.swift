import Foundation

@globalActor
actor AuditActor {
    static let shared = AuditActor()
}

@AuditActor
struct AuditLog {
    private static var entries: [String] = []

    static func record(_ message: String) {
        entries.append(message)
        print("audit:", message)
    }

    static func snapshot() -> [String] {
        entries
    }
}

struct OrderProcessor {
    func process(orderID: Int) async {
        try? await Task.sleep(for: .milliseconds(Int.random(in: 50...150)))
        await AuditLog.record("processed order \(orderID)")
    }
}

func runGlobalActorAuditLogExample() async {
    let processor = OrderProcessor()

    await withTaskGroup(of: Void.self) { group in
        for orderID in 1...5 {
            group.addTask {
                await processor.process(orderID: orderID)
            }
        }
    }

    let entries = await AuditLog.snapshot()
    print("\nAudit entries recorded on one global actor:", entries.count)
    for entry in entries {
        print("-", entry)
    }
}
