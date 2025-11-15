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

    /// Selects and returns an image from the internal storage based on a relative increment,
    /// optionally sticking to a previously selected (cached) image for the current session.
    ///
    /// This method maintains a persisted index in `UserDefaults` under the key `"preludeImageIndex"`.
    /// Each invocation computes a new index by applying `increment`
    /// relative to the previously persisted index and rolls over within the bounds of the
    /// `storage` array. The newly selected image is cached in `sessionPreludeImage` for the
    /// remainder of the actor's lifetime, if `sticky` is `true` and a cached image already exists.
    ///
    /// - Parameters:
    ///   - increment: The relative step to apply to the previously persisted index. Positive values
    ///     move forward, negative values move backward. The index wraps around using modulo arithmetic.
    ///   - sticky: When `true`, if an image has already been selected during this actor's lifetime,
    ///     the cached image is returned and the persisted index is not advanced. When `false`, the
    ///     method computes and selects a new image according to `increment`.
    ///
    /// - Returns: The selected `PreludeImage2626`.
    ///
    /// - Important: If `storage` is empty, this method triggers a `fatalError`. Under normal
    ///   operation, `storage` is populated in `init()` and should contain at least one image.
    ///
    /// - Note: The persisted index stored in `UserDefaults` is zero-based and constrained to the
    ///   range `0..<storage.count`. The modulo operation ensures rollover in both directions.
    func selectNextImage(increment: Int, sticky: Bool) -> PreludeImage2626 {
        guard !storage.isEmpty else {
            fatalError("PreludeImageStore array is empty") // should be covered by init()
        }

        if abs(increment)>1 {
            print("Warning: \"increment\" param for selectNextImage should normally be set to +1 (next) or -1 (prev)")
        }

        if sessionPreludeImage != nil { // if sessionPreludeImage is already set, stick to that "cached" image
            // we already have selected an image earlier in this session
            // but we only stick to that if `sticky` is true
            if sticky { return sessionPreludeImage! }
        }

        // no cached value, so determine what image to use
        let userDefaultsKey = "preludeImageIndex" // id for UserDefaults
        let prevIndex = UserDefaults.standard.integer(forKey: userDefaultsKey) // 0 if missing
        let newIndex = (prevIndex + storage.count + increment) % storage.count // rollover after last array element
        UserDefaults.standard.set(newIndex, forKey: userDefaultsKey) // save persistently

        let newImage = storage[newIndex]
        sessionPreludeImage = newImage
        return newImage
    }

}
