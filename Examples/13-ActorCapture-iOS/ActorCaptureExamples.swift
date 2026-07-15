import AVFoundation

@MainActor
final class BadPrintRecorder {
    private let engine = AVAudioEngine()

    func start() {
        engine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, _ in
            // This closure is created inside a @MainActor method, so it inherits
            // MainActor isolation. Core Audio invokes the block on its render
            // thread, which can trip Swift's runtime executor check.
            print(buffer)
        }

        try? engine.start()
    }
}

private func makePrintTapHandler() -> AVAudioNodeTapBlock {
    { buffer, _ in
        print(buffer)
    }
}

@MainActor
final class FixedPrintRecorder {
    private let engine = AVAudioEngine()

    func start() -> String {
        engine.inputNode.removeTap(onBus: 0)
        engine.inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: nil,
            block: makePrintTapHandler()
        )

        do {
            try engine.start()
            return "Installed a tap whose closure was created outside MainActor isolation."
        } catch {
            return "Installed the fixed tap, but AVAudioEngine did not start: \(error.localizedDescription)"
        }
    }
}

final class AudioProcessingContext: @unchecked Sendable {
    func process(_ buffer: AVAudioPCMBuffer) {
        print("processed \(buffer.frameLength) frames")
    }
}

@MainActor
final class BadContextRecorder {
    private let engine = AVAudioEngine()
    private let context = AudioProcessingContext()

    func start() {
        engine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: nil) { buffer, _ in
            // This captures state through self from an actor-isolated context.
            // The capture is not the root problem; where the callback is created is.
            self.context.process(buffer)
        }
    }
}

private func makeContextTapHandler(context: AudioProcessingContext) -> AVAudioNodeTapBlock {
    { buffer, _ in
        context.process(buffer)
    }
}

@MainActor
final class FixedContextRecorder {
    private let engine = AVAudioEngine()
    private let context = AudioProcessingContext()

    func start() -> String {
        engine.inputNode.removeTap(onBus: 0)
        engine.inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: nil,
            block: makeContextTapHandler(context: context)
        )

        do {
            try engine.start()
            return "Installed a tap that captures context without inheriting MainActor isolation."
        } catch {
            return "Installed the fixed context tap, but AVAudioEngine did not start: \(error.localizedDescription)"
        }
    }
}
