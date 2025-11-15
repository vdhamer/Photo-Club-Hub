//
//  PreludeImageStore2626.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 11/11/2025.
//

import SwiftUI

@available(iOS 26.0, *)
actor PreludeImageStore2626 {
    private var storage = [PreludeImage2626]() // holds images that are loaded by init()
    private var sessionPreludeImage: PreludeImage2626? // initializes to `nil`, cache of image for this session

    // Requirements for these images:
    // 0. there should be at least one image (else fatalerror is triggered). Covered by init().
    // 1. image should be square and have enough resolution (for displaying on a large iPad)
    // 2. image should preferably be colorful (to demonstrate color handling)
    // 3. each image needs to contain an area of pure white (for the initial zoomed-in state)
    init() {
        storage.append(PreludeImage2626(assetName: "2021_FotogroepWaalre_058_square",
                                        copyright: "© Greetje van Son",
                                        copyrightAlignment: PreludeAlignment.bottomLeading,
                                        whiteCoordinates: .init(x: 8, y: 6)))

        storage.append(PreludeImage2626(assetName: "2005_Pimpernel_076_rot_crop_square",
                                        copyright: "© Peter van den Hamer",
                                        copyrightAlignment: PreludeAlignment.bottomTrailing, // (c) to subject distance
                                        whiteCoordinates: .init(x: 3, y: 8)))

        storage.append(PreludeImage2626(assetName: "2023_Cornwall_R5_316_square",
                                        copyright: "© Peter van den Hamer",
                                        copyrightAlignment: PreludeAlignment.bottomLeading,
                                        whiteCoordinates: .init(x: 7, y: 0)))

        storage.append(PreludeImage2626(assetName: "2024_California_R5_340-3-Edit_square",
                                        copyright: "© Peter van den Hamer",
                                        copyrightAlignment: PreludeAlignment.bottomLeading,
                                        whiteCoordinates: .init(x: -2, y: -6)))

        storage.append(PreludeImage2626(assetName: "2025_fgDeGenderExpo_064_square",
                                        copyright: "© Bert Zantingh",
                                        copyrightAlignment: PreludeAlignment.bottomLeading,
                                        whiteCoordinates: .init(x: 4, y: 1)))

        storage.append(PreludeImage2626(assetName: "2025_Texel_R5_025_square",
                                        copyright: "© Peter van den Hamer",
                                        copyrightAlignment: PreludeAlignment.bottomLeading,
                                        whiteCoordinates: .init(x: 4, y: 12)))
    }

    /// Returns the session's selected `PreludeImage`.
    ///
    /// On first invocation, the first  image is selected from internal storage and cached
    /// in `sessionPreludeImage`. Subsequent calls return the same image for the lifetime
    /// of this `PreludeImageStore2626` actor instance.
    ///
    /// - If the storage is ever empty, the function triggers a `fatalError`.
    ///
    /// - Concurrency: This type is an `actor`, so access to `storage` and `sessionPreludeImage`
    ///   is serialized, making this method safe to call from concurrent contexts.
    ///
    /// - Returns: The cached  `PreludeImage` for the current session.
    func selectAnImage() -> PreludeImage2626 {
        guard !storage.isEmpty else {
            fatalError("PreludeImageStore array is empty") // should be covered by init()
        }

        if sessionPreludeImage != nil { // if sessionPreludeImage is already set, stick to that "cached" image
            return sessionPreludeImage! // we already have selected an image earlier in this session
        }

        // no cached value, so determine what image to use
        let userDefaultsKey = "preludeImageIndex" // id for UserDefaults
        let prevIndex = UserDefaults.standard.integer(forKey: userDefaultsKey) // 0 if missing
        let newIndex = (prevIndex + 1) % storage.count // rollover after last array element
        UserDefaults.standard.set(newIndex, forKey: userDefaultsKey) // save persistently

        let newImage = storage[newIndex]
        sessionPreludeImage = newImage
        return newImage
    }

}
