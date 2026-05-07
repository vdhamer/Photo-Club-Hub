//
//  ImageChoice.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 22/04/2026.
//

import Foundation // for URL

/// Chooses between a member’s featured image and the photographer’s image based on a user preference and a “flipped” flag.
struct ImageChoice {

    enum ImageContentType {
        case featuredImageType
        case photographerImageType
    }

    let url: URL
    let content: ImageContentType

    init(member: MemberPortfolio, isImageFlipped: Bool, preferenceForFeaturedImage: Bool) {

        if isImageFlipped == false {
            if preferenceForFeaturedImage {
//                return ImageChoice(url: member.featuredImageThumbnail, content: .featuredImageType) // non-optional
                self.url = member.featuredImageThumbnail
                self.content = .featuredImageType
                return
            }

            if let photographerImageURL = member.photographer.photographerImage {
//                return ImageChoice(url: photographerImageURL, content: .photographerImageType)
                self.url = photographerImageURL
                self.content = .photographerImageType
                return
            }
        }

        if isImageFlipped {
            if preferenceForFeaturedImage == true, let photographerImageURL = member.photographer.photographerImage {
//                return ImageChoice(url: photographerImageURL, content: .photographerImageType)
                self.url = photographerImageURL
                self.content = .photographerImageType
                return
            }

            if preferenceForFeaturedImage == false {
//                return ImageChoice(url: member.featuredImageThumbnail, content: .featuredImageType)
                self.url = member.featuredImageThumbnail
                self.content = .featuredImageType
                return
            }
        }

//        return ImageChoice(url: member.featuredImageThumbnail, content: .featuredImageType)
        self.url = member.featuredImageThumbnail
        self.content = .featuredImageType
    }

}
