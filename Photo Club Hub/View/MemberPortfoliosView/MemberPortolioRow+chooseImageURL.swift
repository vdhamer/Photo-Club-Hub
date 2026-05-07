//
//  MemberPortolioRow+chooseImageURL.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 22/04/2026.
//

import Foundation // for URL

extension MemberPortfolioRow {

    enum ImageContentType {
        case featuredImageType
        case photographerImageType
    }

    struct ImageChoice {
        let url: URL
        let content: ImageContentType
    }

    func chooseImageURL(member: MemberPortfolio, isImageFlipped: Bool) -> ImageChoice {
        let preferenceForFeaturedImage = PreferencesViewModel().preferences.preferenceForFeaturedImage

        if isImageFlipped == false {
            if preferenceForFeaturedImage {
                return ImageChoice(url: member.featuredImageThumbnail, content: .featuredImageType) // non-optional
            }

            if let photographerImageURL = member.photographer.photographerImage {
                return ImageChoice(url: photographerImageURL, content: .photographerImageType)
            }
        }

        if isImageFlipped {
            if preferenceForFeaturedImage == true, let photographerImageURL = member.photographer.photographerImage {
                return ImageChoice(url: photographerImageURL, content: .photographerImageType)
            }

            if preferenceForFeaturedImage == false {
                return ImageChoice(url: member.featuredImageThumbnail, content: .featuredImageType)
            }
        }

        return ImageChoice(url: member.featuredImageThumbnail, content: .featuredImageType)
    }

}
