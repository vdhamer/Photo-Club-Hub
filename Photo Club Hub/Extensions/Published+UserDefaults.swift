//
//  Published+UserDefaults.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 25/12/2021.
//

import Combine // for AnyCancellable
import Foundation // for UserDefaults

// https://www.fivestars.blog/swiftui/app-scene-storage.html

// @Published with integrated support for updating UserDefaults
// There may be a more modern way of doing this without using Combine.
extension Published where Value: Codable {

    /// Initializes a `Published` value backed by `UserDefaults`.
    ///
    /// Loads the initial value by decoding JSON stored under `key` (if present), otherwise uses
    /// `wrappedValue`. Subsequent changes are encoded as JSON and saved to `UserDefaults`.
    ///
    /// - Parameters:
    ///   - wrappedValue: Default value when no stored value exists or decoding fails.
    ///   - key: `UserDefaults` key used to read and write the value.
    ///   - cancellableSet: Storage for the persistence subscription; keep it alive for as long as needed.
    ///   - store: `UserDefaults` instance to use. Defaults to `.standard`.

    public init(wrappedValue defaultValue: Value,
                _ key: String,
                cancellableSet: inout Set<AnyCancellable>,
                store: UserDefaults? = nil
    ) {

        let store: UserDefaults = store ?? .standard

        if
            let data = store.data(forKey: key),
            let value = try? JSONDecoder().decode(Value.self, from: data) {
            self.init(initialValue: value)
        } else {
            self.init(initialValue: defaultValue)
        }

        projectedValue
            .sink { newValue in
                let data = try? JSONEncoder().encode(newValue)
                store.set(data, forKey: key)
            }
            .store(in: &cancellableSet)

    }
}
