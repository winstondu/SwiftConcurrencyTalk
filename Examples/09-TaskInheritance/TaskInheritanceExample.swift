import Foundation

enum RequestContext {
    @TaskLocal static var traceID = "none"
}

actor Recorder {
    private var messages: [String] = []

    func runDemo() async {
        messages.append("parent actor started with trace \(RequestContext.traceID)")

        let inherited = Task {
            messages.append("inherited Task updated actor state directly")
            return "inherited trace: \(RequestContext.traceID)"
        }

        let detached = Task.detached {
            await self.recordFromDetached("detached Task updated actor state through await")
            return "detached trace: \(RequestContext.traceID)"
        }

        print(await inherited.value)
        print(await detached.value)
    }

    private func recordFromDetached(_ message: String) {
        messages.append(message)
    }

    func snapshot() -> [String] {
        messages
    }
}

func runTaskInheritanceExample() async {
    let recorder = Recorder()

    await RequestContext.$traceID.withValue("checkout-42") {
        await recorder.runDemo()
    }

    let messages = await recorder.snapshot()

    print("\nRecorder messages:")
    for message in messages {
        print("-", message)
    }

    print("\nThe inherited Task kept the task-local trace and actor isolation.")
    print("The detached Task did not inherit the task-local trace and had to hop back to the actor with await.")
}
