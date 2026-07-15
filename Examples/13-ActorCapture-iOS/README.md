# 13 - Actor Capture In Callbacks

This iOS-only target demonstrates a callback gotcha that is easy to miss when a framework invokes a closure from its own thread.

`AVAudioEngine.inputNode.installTap` stores an `AVAudioNodeTapBlock`, then Core Audio invokes that block on the audio render thread. If the block is created inside a `@MainActor` method, the closure can inherit main-actor isolation even though Core Audio will not call it from the main actor. When the render thread invokes that inherited closure, Swift can trap on a runtime executor check.

The fix is to create the callback outside the actor-isolated context:

```swift
private func makeTapHandler() -> AVAudioNodeTapBlock {
    { buffer, _ in
        print(buffer)
    }
}

@MainActor
final class Recorder {
    private let engine = AVAudioEngine()

    func start() {
        engine.inputNode.installTap(
            onBus: 0,
            bufferSize: 1024,
            format: nil,
            block: makeTapHandler()
        )
    }
}
```

`ActorCaptureExamples.swift` includes both the bad and fixed shapes, including a captured-state version. The bad recorders compile as teaching examples but are not invoked by the app UI by default, because they are intentionally crash-prone.

The key point is: the fix is not "capture less." The fix is "create the callback outside the actor-isolated context."

Build for the iOS simulator:

```sh
xcodebuild -project ConcurrencyInSwift.xcodeproj -scheme 13_ActorCapture_iOS -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath build/DerivedData build
```
