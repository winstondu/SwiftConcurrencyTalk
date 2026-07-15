import Foundation

final class CustomExecutor: SerialExecutor {
    private let queue: DispatchQueue

    init(label: String) {
        self.queue = DispatchQueue(label: label)
    }

    func enqueue(_ job: consuming ExecutorJob) {
        let unownedJob = UnownedJob(job)
        let executor = asUnownedSerialExecutor()

        queue.async {
            unownedJob.runSynchronously(on: executor)
        }
    }

    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

@globalActor
actor OtherActor: GlobalActor {
    static let shared = OtherActor()

    private static let executor = CustomExecutor(label: "course.other-actor")

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        Self.executor.asUnownedSerialExecutor()
    }
}

@OtherActor
enum OtherActorLog {
    private static var markers: [String] = []

    static func record(_ marker: String) {
        OtherActor.assertIsolated()
        markers.append(marker)
        print("other-actor:", marker)
    }

    static func snapshot() -> [String] {
        markers
    }
}

func generateTaskOnSpecialExecutor(marker: String) -> Task<String, Never> {
    Task { @OtherActor in
        OtherActorLog.record("task \(marker) reached OtherActor")
        return "task \(marker) completed"
    }
}

func runCustomExecutorOtherActorExample() async {
    print("\nCustom executor global actor")

    let tasks = ["a", "b", "c"].map { marker in
        generateTaskOnSpecialExecutor(marker: marker)
    }

    for task in tasks {
        print(await task.value)
    }

    let markers = await OtherActorLog.snapshot()
    print("recorded markers:", markers.joined(separator: ", "))
}
