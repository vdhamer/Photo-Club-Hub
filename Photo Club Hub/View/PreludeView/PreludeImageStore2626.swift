//
//  PreludeImageStore2626.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 11/11/2025.
//

import SwiftUI

@available(iOS 26.0, *)
actor PreludeImageStore2626 {
    private var storage: [Int: PreludeImage] = [:]
    private var sessionPreludeImage: PreludeImage? // implicitly initialized to nil

    init() {
        Task {
            await self.initialize() // to trigger async functions from a sync init()
        }
    }

    // Requirements for these images:
    // 0. should be at least one image (else fatalerror is triggered)
    // 1. should be square and high enough resolution (for displaying on a large iPad)
    // 2. should be colorful (to demonstrate color handling)
    // 3. should contain an area of pretty pure white (for the initial zoomed-in state)
    private func initialize() async {
        await self.append(PreludeImage(assetName: "2021_FotogroepWaalre_058_square",
                                       copyright: "© Greetje van Son",
                                       whiteCoordinates: .init(x: 8, y: 6)))

        await self.append(PreludeImage(assetName: "2025_fgDeGenderExpo_064_square",
                                       copyright: "© Bert Zantingh",
                                       whiteCoordinates: .init(x: 4, y: 1)))

        await self.append(PreludeImage(assetName: "2023_Cornwall_R5_316_square",
                                       copyright: "© Peter van den Hamer",
                                       whiteCoordinates: .init(x: 7, y: 0)))

        await self.append(PreludeImage(assetName: "2025_Texel_R5_025_square",
                                       copyright: "© Peter van den Hamer",
                                       whiteCoordinates: .init(x: 4, y: 12)))

        await self.append(PreludeImage(assetName: "2025_Texel_X100vi_071_square",
                                       copyright: "© Peter van den Hamer",
                                       whiteCoordinates: .init(x: 8, y: 5)))

        await self.append(PreludeImage(assetName: "2024_California_R5_340-3-Edit_square",
                                       copyright: "© Peter van den Hamer",
                                       whiteCoordinates: .init(x: -2, y: -6)))
    }

    /// Returns the session's selected `PreludeImage`.
    ///
    /// On first invocation, a random image is selected from internal storage and cached
    /// in `sessionPreludeImage`. Subsequent calls return the same image for the lifetime
    /// of this `PreludeImageStore2626` actor instance.
    ///
    /// - Important: This method assumes the store has been initialized and contains at least
    ///   one image. If the storage is empty, the function triggers a `fatalError`.
    ///
    /// - Concurrency: This type is an `actor`, so access to `storage` and `sessionPreludeImage`
    ///   is serialized, making this method safe to call from concurrent contexts.
    ///
    /// - Returns: The cached random `PreludeImage` for the current session.
    func getRandomPreludeImage() async -> PreludeImage {
        guard !storage.isEmpty else { // shouldn't happen due to code in initializer
            fatalError("PreludeImageStore array is empty")
        }
        if sessionPreludeImage != nil {
            return sessionPreludeImage! // we already have selected an image
        } else {
            sessionPreludeImage = self[Int.random(in: 1..<(storage.count + 1))]
            return sessionPreludeImage!
        }
    }

    func append(_ preludeImage: PreludeImage) async {
        let newKey = storage.count + 1 // assign a new identifier
        storage[newKey] = preludeImage
    }

        subscript(key: Int) -> PreludeImage? {
            storage[key] // read-only
        }

// MARK: - unused functions (need to recheck once in a while)

    func count() -> Int {
        storage.count
    }

    func get(_ key: Int) -> PreludeImage? { // should work, but isn't used yet
        storage[key]
    }
}

@available(iOS 26.0, *)
struct PreludeImage {
    let assetName: String // name in assets
    let copyright: String // who made the image
    let whiteCoordinates: OffsetVectorInCells2626 // where to find a pure white location
}
