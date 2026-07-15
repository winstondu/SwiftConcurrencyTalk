import Foundation

struct SimulatedRequest: Sendable {
    let url: URL
    let delayMilliseconds: UInt64
    let shouldFail: Bool
}

enum SimulatedRequestError: Error, CustomStringConvertible {
    case failed(URL)

    var description: String {
        switch self {
        case .failed(let url):
            "simulated request failed for \(url.lastPathComponent)"
        }
    }
}

func runBoundedRequestLoadingExample() async {
    print("")
    print("== Bounded request loading ==")

    let requests = [
        SimulatedRequest(url: URL(string: "https://course.example/images/hero.png")!, delayMilliseconds: 90, shouldFail: false),
        SimulatedRequest(url: URL(string: "https://course.example/images/avatar.png")!, delayMilliseconds: 30, shouldFail: false),
        SimulatedRequest(url: URL(string: "https://course.example/images/broken.png")!, delayMilliseconds: 20, shouldFail: true),
        SimulatedRequest(url: URL(string: "https://course.example/images/background.png")!, delayMilliseconds: 60, shouldFail: false),
        SimulatedRequest(url: URL(string: "https://course.example/images/icon.png")!, delayMilliseconds: 40, shouldFail: false)
    ]

    let loadedData = await sendSimulatedRequests(requests: requests, batchSize: 2)

    print("")
    print("== Request results in input order ==")
    for request in requests {
        let name = request.url.lastPathComponent
        if let data = loadedData[request.url] ?? nil {
            print("\(name): loaded \(data.count) bytes")
        } else {
            print("\(name): unavailable")
        }
    }
}

func sendSimulatedRequests(requests: [SimulatedRequest], batchSize: Int = 10) async -> [URL: Data?] {
    guard batchSize > 0 else {
        return [:]
    }

    return await withTaskGroup(of: Result<(URL, Data), Error>.self, returning: [URL: Data?].self) { group in
        var dataForURL: [URL: Data?] = [:]
        var indexOfNextRequest = 0

        func addNextRequestIfAvailable() {
            guard indexOfNextRequest < requests.count else {
                return
            }

            let request = requests[indexOfNextRequest]
            indexOfNextRequest += 1

            group.addTask {
                do {
                    let data = try await loadSimulatedData(for: request)
                    return .success((request.url, data))
                } catch {
                    return .failure(error)
                }
            }
        }

        for _ in 0..<min(requests.count, batchSize) {
            addNextRequestIfAvailable()
        }

        while let result = await group.next() {
            addNextRequestIfAvailable()

            switch result {
            case .success(let (url, data)):
                print("loaded \(url.lastPathComponent)")
                dataForURL[url] = data
            case .failure(let error):
                print(error)
            }
        }

        return dataForURL
    }
}

private func loadSimulatedData(for request: SimulatedRequest) async throws -> Data {
    try await Task.sleep(nanoseconds: request.delayMilliseconds * 1_000_000)

    if request.shouldFail {
        throw SimulatedRequestError.failed(request.url)
    }

    return Data("bytes for \(request.url.lastPathComponent)".utf8)
}
