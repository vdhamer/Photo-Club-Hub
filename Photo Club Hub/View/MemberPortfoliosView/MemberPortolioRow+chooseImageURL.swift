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

    func chooseImageURL(member: MemberPortfolio, isImageFlipped: Bool) -> ImageChoice {
        let preferenceForFeaturedImage = PreferencesViewModel().preferences.preferenceForFeaturedImage

        if isImageFlipped == false {
            if preferenceForFeaturedImage {
                return ImageChoice(url: member.featuredImageThumbnail, content: .featuredImage) // non-optional
            }

            if let photographerImageURL = member.photographer.photographerImage {
                return ImageChoice(url: photographerImageURL, content: .photographerImage)
            }
        }

        if isImageFlipped {
            if preferenceForFeaturedImage == true, let photographerImageURL = member.photographer.photographerImage {
                return ImageChoice(url: photographerImageURL, content: .photographerImage)
            }

            if preferenceForFeaturedImage == false {
                return ImageChoice(url: member.featuredImageThumbnail, content: .featuredImage)
            }
        }

        return ImageChoice(url: member.featuredImageThumbnail, content: .featuredImage)
    }

}
