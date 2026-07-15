import Foundation

@MainActor
func runRegularTaskMainActorInheritanceExample() async {
    print("")
    print("== Regular Task inherits MainActor isolation ==")

    let task = Task {
        MainActor.assertIsolated()
        return "Task body ran on MainActor"
    }

    print(await task.value)
}

@MainActor
func runAsyncLetTaskMainActorInheritanceCrashExample() async {
    print("")
    print("== async let Task does not inherit MainActor isolation ==")
    print("This scenario intentionally traps when the Task body asserts MainActor isolation.")

    async let task = Task {
        MainActor.assertIsolated()
        return "Task body ran on MainActor"
    }

    print(await task.value)
}
