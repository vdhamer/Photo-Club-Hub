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

    init() {
        Task {
            await self.initialize() // to trigger async functions from a sync init()
        }
    }

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

        await self.append(PreludeImage(assetName: "2024_California_R5_340-3-Edit_square",
                                       copyright: "© Peter van den Hamer",
                                       whiteCoordinates: .init(x: -2, y: -6)))
    }

    func get(_ key: Int) -> PreludeImage? {
        storage[key]
    }

    func getRandomPreludeImage() async -> PreludeImage {
        guard !storage.isEmpty else { // shouldn't happen due to code in initializer
            fatalError("PreludeImageStore array is empty")
        }
        let randomIndex = Int.random(in: 1..<(storage.count + 1))
        return self[randomIndex]!
    }

    func append(_ preludeImage: PreludeImage) async {
        let newKey = storage.count + 1 // assign a new identifier
        storage[newKey] = preludeImage
    }

    func count() -> Int {
        storage.count
    }

    subscript(key: Int) -> PreludeImage? {
        storage[key] // read-only
    }
}

@available(iOS 26.0, *)
struct PreludeImage {
    let assetName: String // name in assets
    let copyright: String // who made the image
    let whiteCoordinates: OffsetVectorInCells2626 // where to find a pure white location
}
