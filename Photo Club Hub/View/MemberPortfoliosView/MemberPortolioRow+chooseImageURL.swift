//
//  MemberPortolioRow+chooseImageURL.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 22/04/2026.
//

import Foundation // for URL

extension MemberPortfolioRow {

    enum ImageContent {
        case featuredImage
        case photographerImage
    }

    struct ImageChoice {
        let url: URL
        let content: ImageContent
    }

    func chooseImageURL(member: MemberPortfolio) -> ImageChoice {
        let preferenceForFeaturedImage = PreferencesViewModel().preferences.preferenceForFeaturedImage

        if preferenceForFeaturedImage {
            return ImageChoice(url: member.featuredImageThumbnail, content: .featuredImage) // non-optional
        }

        if let photographerImageURL = member.photographer.photographerImage {
            return ImageChoice(url: photographerImageURL, content: .photographerImage)
        }

        return ImageChoice(url: member.featuredImageThumbnail, content: .featuredImage)
    }

}
