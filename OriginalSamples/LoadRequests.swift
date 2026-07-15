//
//  LoadRequests.swift
//  OriginalSamples
//
//  Created by Winston Du on 1/28/25.
//

import Foundation


// Async Method to send requests concurrently, up to "batchSize"
func sendRequests(urls: [URL], batchSize: Int = 10) async throws -> [URL: Data?] {
    await withThrowingTaskGroup(of: (URL, (Data, URLResponse)).self, returning: [URL:Data?].self) { group in
        // Add initial group.
        var dataForURL: [URL: Data?] = [:]
        for index in 0..<min(urls.count, batchSize) {
            _ = group.addTaskUnlessCancelled { [index] in
                let url = urls[index]
                let dataAndResponse = try await URLSession.shared.data(from: url)
                return (url, dataAndResponse)
              }
        }
        var indexOfNextUrl = batchSize
        // Then, once we start getting data from initial, enqueue more tasks to
        // the group
        // Also possible is:
        // for try await resultData in group {
        while let result = await group.nextResult() {
            // Add another task into the group
            if indexOfNextUrl < urls.count {
                _ = group.addTaskUnlessCancelled { [indexOfNextUrl] in // Note use capture to copy.
                    let url = urls[indexOfNextUrl]
                    let dataAndResponse = try await URLSession.shared.data(from: url)
                    return (url, dataAndResponse)
                }
                indexOfNextUrl += 1
            }
            
            guard case .success(let resultData) = result else {
                continue
            }
            let (url, dataAndResponse) = resultData
            let (data, response) = dataAndResponse
            dataForURL[url] = data
        }
        return dataForURL
    }
}

func requestsExample() throws -> Task<Void, Error> {
    return Task {
        let urls = [
            URL(string: "https://backbone.com/_next/image/?url=%2F_next%2Fstatic%2Fmedia%2Fcall-of-duty.fbb5a4cd.png&w=1920&q=75&dpl=dpl_6pmb4a9PPtXzt4Yn4nzp5qEEKLKB")!,
            URL(string: "https://lh3.googleusercontent.com/X7_CHCjksOZYu4gIGa45Edj1tMymdiz2o3pbL6HqqVEszWvPzrM6iIwHzaWNqgsWLcm7VmHCQyuQowWSSImQYLF8qW48zmZ-rx309F3c=s0")!,
            URL(string: "http://bla.xyz/")!, // invalid
        ]
        do {
            let results = try await sendRequests(urls: urls, batchSize: 10)
            print("OK")
            for url in urls {
                guard let image = results[url] else {
                    print("Did not find image for \(url)")
                    return
                }
                print("Found image for \(url)")
            }
        } catch {
            print("Issue!")
        }
    }
}
