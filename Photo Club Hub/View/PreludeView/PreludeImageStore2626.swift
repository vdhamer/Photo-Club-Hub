//
//  PreludeImageStore2626.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 11/11/2025.
//

import SwiftUI

@available(iOS 26.0, *)
actor PreludeImageStore2626 {
    private var storage: [Int: PreludeImage2626] = [:]
    private var sessionPreludeImage: PreludeImage2626? // initializes to `nil`

    init() {
        Task {
            await self.initialize() // to trigger async functions from a sync init()
        }
    }

    // Requirements for these images:
    // 0. there should be at least one image (else fatalerror is triggered)
    // 1. image should be square and have enough resolution (for displaying on a large iPad)
    // 2. image should be colorful (to demonstrate color handling)
    // 3. image need to ccontain an area of pretty pure white (for the initial zoomed-in state)
    private func initialize() async {
        await self.append(PreludeImage2626(assetName: "2021_FotogroepWaalre_058_square",
                                           copyright: "© Greetje van Son",
                                           whiteCoordinates: .init(x: 8, y: 6)))

        await self.append(PreludeImage2626(assetName: "2025_fgDeGenderExpo_064_square",
                                           copyright: "© Bert Zantingh",
                                           whiteCoordinates: .init(x: 4, y: 1)))

        await self.append(PreludeImage2626(assetName: "2023_Cornwall_R5_316_square",
                                           copyright: "© Peter van den Hamer",
                                           whiteCoordinates: .init(x: 7, y: 0)))

        await self.append(PreludeImage2626(assetName: "2025_Texel_R5_025_square",
                                           copyright: "© Peter van den Hamer",
                                           whiteCoordinates: .init(x: 4, y: 12)))

        await self.append(PreludeImage2626(assetName: "2024_California_R5_340-3-Edit_square",
                                           copyright: "© Peter van den Hamer",
                                           whiteCoordinates: .init(x: -2, y: -6)))

        await self.append(PreludeImage2626(assetName: "2005_Pimpernel_076_rot_crop_square",
                                           copyright: "© Peter van den Hamer",
                                           copyrightAlignment: PreludeAlignment.bottomTrailing,
                                           whiteCoordinates: .init(x: 3, y: 8)))
    }

    /// Returns the session's selected `PreludeImage`.
    ///
    /// On first invocation, an  image is selected from internal storage and cached
    /// in `sessionPreludeImage`. Subsequent calls return the same image for the lifetime
    /// of this `PreludeImageStore2626` actor instance.
    ///
    /// - Important: This method assumes the store has been initialized and contains at least
    ///   one image. If the storage is empty, the function triggers a `fatalError`.
    ///
    /// - Concurrency: This type is an `actor`, so access to `storage` and `sessionPreludeImage`
    ///   is serialized, making this method safe to call from concurrent contexts.
    ///
    /// - Returns: The cached  `PreludeImage` for the current session.
    func get() async -> PreludeImage2626 {
        guard !storage.isEmpty else {
            fatalError("PreludeImageStore array is empty")
        }
        if sessionPreludeImage != nil {
            return sessionPreludeImage! // we already have selected an image
        } else {
            if let cached = sessionPreludeImage {
                return cached
            } else { // no cached value, so determine what image to use
                let userDefaultsKey = "preludeImageIndex"
                let prevIndex = UserDefaults.standard.integer(forKey: userDefaultsKey) // 0 if missing
                let total = await count()
                let index = (prevIndex % total) + 1 // index in range 1...total
                UserDefaults.standard.set(index, forKey: userDefaultsKey)

                guard let image = await get(index) else {
                    fatalError("PreludeImageStore: invalid index \(index)")
                }
                sessionPreludeImage = image
                return image
            }
        }
    }

    func get(_ key: Int) async -> PreludeImage2626? {
        storage[key]
    }

    func append(_ preludeImage: PreludeImage2626) async {
        let newKey = storage.count + 1 // assign a new identifier
        storage[newKey] = preludeImage
    }

    subscript(key: Int) -> PreludeImage2626? {
        storage[key] // read-only
    }

    func count() async -> Int {
        storage.count
    }

    // MARK: - Navigation helpers for swipe gestures

    /// Advances to the next image (intended for a leftward swipe) and returns it.
    /// Persists the new index in UserDefaults and updates the session cache.
    func advanceToNextImage() async -> PreludeImage2626 {
        guard await count() > 0 else {
            fatalError("PreludeImageStore array is empty")
        }
        let userDefaultsKey = "preludeImageIndex"
        let prevIndex = UserDefaults.standard.integer(forKey: userDefaultsKey) // 0 if missing
        let total = await count()
        let index = (prevIndex % total) + 1 // next index in 1...total
        UserDefaults.standard.set(index, forKey: userDefaultsKey)

        guard let image = await get(index) else {
            fatalError("PreludeImageStore: invalid index \(index)")
        }
        sessionPreludeImage = image
        return image
    }

    /// Goes to the previous image (intended for a rightward swipe) and returns it.
    /// Persists the new index in UserDefaults and updates the session cache.
    func advanceToPreviousImage() async -> PreludeImage2626 {
        guard await count() > 0 else {
            fatalError("PreludeImageStore array is empty")
        }
        let userDefaultsKey = "preludeImageIndex"
        let prevIndex = UserDefaults.standard.integer(forKey: userDefaultsKey) // 0 if missing
        let total = await count()
        // Map 0 (no prior selection) to 1 as a starting point, then step back with rollover.
        let current = (prevIndex == 0) ? 1 : prevIndex
        let index = (current == 1) ? total : (current - 1)
        UserDefaults.standard.set(index, forKey: userDefaultsKey)

        guard let image = await get(index) else {
            fatalError("PreludeImageStore: invalid index \(index)")
        }
        sessionPreludeImage = image
        return image
    }
}
