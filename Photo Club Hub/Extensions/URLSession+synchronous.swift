//
//  URLSession+synchronous.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/07/2023.
//

import Foundation

extension URLSession {

    // swiftlint:disable:next large_tuple
    func synchronousDataTask(from url: URL) -> (Data?, URLResponse?, Error?) {
        // (synchronous-http-request-via-nsurlsession-in-swift)[https://stackoverflow.com/questions/26784315]
        nonisolated(unsafe) var data: Data?     // protected by semaphore
        nonisolated(unsafe) var response: URLResponse?
        nonisolated(unsafe) var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: url) { // asynchronous
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        }
        dataTask.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return (data, response, error)
    }

}
