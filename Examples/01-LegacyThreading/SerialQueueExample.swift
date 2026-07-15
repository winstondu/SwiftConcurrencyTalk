import Foundation

func runSerialQueueExample() {
    print("")
    print("== Serial DispatchQueue ==")

    let queue = DispatchQueue(label: "example.serial")
    let finished = DispatchSemaphore(value: 0)

    for value in 1...3 {
        queue.async {
            print("serial job \(value)")
            if value == 3 {
                finished.signal()
            }
        }
    }

    finished.wait()
}
