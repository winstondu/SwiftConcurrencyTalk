import Foundation

@globalActor
actor TaskInheritanceActor: GlobalActor {
    static let shared = TaskInheritanceActor()
}

@TaskInheritanceActor
final class GlobalActorIsolatedClass {
    func startTasksFromIsolatedClass() async {
        print("\nGlobal-actor-isolated class")

        let tasks = ["a", "b", "c"].map { label in
            Task {
                TaskInheritanceActor.assertIsolated()
                return "\(label): Task inherited TaskInheritanceActor isolation"
            }
        }

        await printTaskResults(tasks)
    }
}

actor ActorInstanceTaskCreator {
    private var count = 0

    func startTaskWithSelfAliasButNoSelfReference() async {
        print("\nActor method with an actor alias, but no direct self reference")

        let actor = self
        let task = Task {
            actor.assertIsolated()
            return "This line is never reached"
        }

        print(await task.value)
    }

    func startTaskWithSelfReference() async {
        print("\nActor method with a self reference in the Task body")

        let tasks = ["a", "b", "c"].map { label in
            Task {
                self.assertIsolated()
                count += 1
                return "\(label): Task is isolated to this actor; count is \(count)"
            }
        }

        await printTaskResults(tasks)
    }
}

final class NonisolatedTaskCreator: Sendable {
    nonisolated func startTaskFromNonisolatedMethod() async {
        print("\nNonisolated method")

        let task = Task {
            "Task body is not isolated just because the caller was isolated"
        }

        print(await task.value)
    }
}

func runGlobalActorClassTaskInheritanceExample() async {
    let example = GlobalActorIsolatedClass()
    await example.startTasksFromIsolatedClass()
}

func runActorInstanceTaskInheritanceGotchaExample() async {
    let example = ActorInstanceTaskCreator()

    await example.startTaskWithSelfReference()
}

func runActorInstanceTaskInheritanceCrashExample() async {
    let example = ActorInstanceTaskCreator()

    await example.startTaskWithSelfAliasButNoSelfReference()
}

func runExplicitGlobalActorTaskAnnotationExample() async {
    print("\nExplicit global-actor Task annotation")

    let tasks = ["a", "b", "c"].map { label in
        Task { @TaskInheritanceActor in
            TaskInheritanceActor.assertIsolated()
            return "\(label): Task body explicitly runs on TaskInheritanceActor"
        }
    }

    await printTaskResults(tasks)
}

@MainActor
func runNonisolatedTaskCreationGotchaExample() async {
    MainActor.assertIsolated()

    let example = NonisolatedTaskCreator()
    await example.startTaskFromNonisolatedMethod()
}

private func printTaskResults(_ tasks: [Task<String, Never>]) async {
    for task in tasks {
        print(await task.value)
    }
}
