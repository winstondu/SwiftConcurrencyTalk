import SwiftUI

struct ContentView: View {
    @State private var output = "Choose a fixed example to install an AVAudioEngine tap."
    @State private var printRecorder = FixedPrintRecorder()
    @State private var contextRecorder = FixedContextRecorder()

    var body: some View {
        NavigationStack {
            List {
                Section("Fixed Examples") {
                    Button("Install print tap") {
                        output = printRecorder.start()
                    }

                    Button("Install captured-state tap") {
                        output = contextRecorder.start()
                    }
                }

                Section("Result") {
                    Text(output)
                        .font(.body.monospaced())
                }

                Section("Teaching Point") {
                    Text("The fix is not to capture less. The fix is to create Core Audio's callback outside the actor-isolated context that installs it.")
                }
            }
            .navigationTitle("Actor Capture")
        }
    }
}
