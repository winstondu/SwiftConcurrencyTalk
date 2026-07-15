fileprivate enum Scenario: Int {
    // Uses async let when the parallel child operations are known up front.
    case fixedParallelWork
    // Shows a regular Task inheriting MainActor isolation from its caller.
    case regularTaskMainActorInheritance
    // Shows the async let Task isolation trap by asserting MainActor inheritance.
    case asyncLetTaskMainActorInheritanceCrash
}

fileprivate let selectedScenarios: [Scenario] = [
    .asyncLetTaskMainActorInheritanceCrash,
]

print("async let examples")
if selectedScenarios.contains(.fixedParallelWork) {
    await runFixedParallelWorkExample()
}
if selectedScenarios.contains(.regularTaskMainActorInheritance) {
    await runRegularTaskMainActorInheritanceExample()
}
if selectedScenarios.contains(.asyncLetTaskMainActorInheritanceCrash) {
    await runAsyncLetTaskMainActorInheritanceCrashExample()
}
print("")
print("async let works best when the number of child operations is known up front")
print("Done")
