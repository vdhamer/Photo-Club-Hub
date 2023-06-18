//
//  Published+UserDefaults.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 25/12/2021.
//

import Combine // for AnyCancellable
import Foundation // for UserDefaults

// https://www.fivestars.blog/swiftui/app-scene-storage.html

private var cancellableSet: Set<AnyCancellable> = []

extension Published where Value: Codable {
    init(wrappedValue defaultValue: Value, _ key: String, store: UserDefaults? = nil) {
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
