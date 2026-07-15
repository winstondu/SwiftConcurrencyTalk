fileprivate enum Scenario: Int {
    // Baseline: Task inherits actor context and task-local values; Task.detached does not.
    case taskInheritance

    // A Task created inside a global-actor-isolated class method inherits that global actor.
    case globalActorClassTaskInheritance

    // Actor instance isolation is inherited when the Task body directly uses self.
    case actorInstanceTaskInheritanceGotcha

    // Intentional crash: an alias to self does not make the Task inherit actor isolation.
    case actorInstanceTaskInheritanceCrash

    // The explicit spelling for making a Task body run on a specific global actor.
    case explicitGlobalActorTaskAnnotation

    // A Task created inside a nonisolated method is not isolated just because its caller was.
    case nonisolatedTaskCreationGotcha
}

fileprivate let selectedScenarios: [Scenario] = [
//    .taskInheritance,
//    .globalActorClassTaskInheritance,
//    .actorInstanceTaskInheritanceGotcha,
    .explicitGlobalActorTaskAnnotation,
//    .nonisolatedTaskCreationGotcha,
]

if selectedScenarios.contains(.taskInheritance) {
    await runTaskInheritanceExample()
}

if selectedScenarios.contains(.globalActorClassTaskInheritance) {
    await runGlobalActorClassTaskInheritanceExample()
}

if selectedScenarios.contains(.actorInstanceTaskInheritanceGotcha) {
    await runActorInstanceTaskInheritanceGotchaExample()
}

if selectedScenarios.contains(.actorInstanceTaskInheritanceCrash) {
    await runActorInstanceTaskInheritanceCrashExample()
}

if selectedScenarios.contains(.explicitGlobalActorTaskAnnotation) {
    await runExplicitGlobalActorTaskAnnotationExample()
}

if selectedScenarios.contains(.nonisolatedTaskCreationGotcha) {
    await runNonisolatedTaskCreationGotchaExample()
}



import Foundation

enum DemoError: Error {

    case boom

}

func demo() async {

    print("before group")

    await withThrowingTaskGroup(of: Void.self) { group in

        group.addTask {

            try await Task.sleep(nanoseconds: 600_000_000)

            print("A finished normally")

        }

        group.addTask {

            try await Task.sleep(nanoseconds: 200_000_000)

            print("B throws")

            throw DemoError.boom

        }

        print("returning normally from group body")

        return

        // Important: we do NOT call `try await group.next()`.

        // So B's error is never propagated out of the group body.

    }

    print("after group")

}




