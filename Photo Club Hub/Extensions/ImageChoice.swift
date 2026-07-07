//
//  ImageChoice.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 22/04/2026.
//

import Foundation // for URL

/// Picks which of a member's two images (featured vs. photographer portrait) to display, and exposes its URL.
///
/// The choice is driven by the user's Preferences setting and a per-thumbnail flip toggle,
/// with a fallback to whichever image is available.
struct ImageChoice {

    /// Identifies the two candidate image types that can be selected.
    enum ImageContentType: String {
        case featured
        case photographer
    }

    /// URL of the selected image (featuredImage or photographerImage).
    let url: URL
    /// Indicates which of the two images was selected.
    let content: ImageContentType

    /// Selects an image for a given `member`, honoring the user's preference and the current flip state.
    /// - Parameters:
    ///   - member: The portfolio supplying the candidate image URLs.
    ///   - isImageFlipped: When `true`, swaps the preferred and fallback choices (e.g. after a tap-to-toggle).
    ///   - preferenceForFeaturedImage: When `true`, the featured image is preferred over the photographer portrait.
    init(member: MemberPortfolio, isImageFlipped: Bool, settingsForFeaturedImage: Bool) {
        // Determine the preferred order based on the setting in Preferences and the flip state
        let preference: ImageContentType
        let alternative: ImageContentType

        if settingsForFeaturedImage {
            preference = isImageFlipped ? .photographer : .featured
            alternative = isImageFlipped ? .featured : .photographer
        } else {
            preference = isImageFlipped ? .featured : .photographer
            alternative = isImageFlipped ? .photographer : .featured
        }

        // Pick the first available in the chosen order, fallback to featured
        if let primaryURL = url(for: preference) {
            self.url = primaryURL
            self.content = preference
        } else if let secondaryURL = url(for: alternative) {
            self.url = secondaryURL
            self.content = alternative
        } else {
            self.url = member.featuredImageThumbnail
            self.content = .featured
        }

        // Helper to get a URL for a given content type
        func url(for type: ImageContentType) -> URL? {
            switch type {
            case .featured:
                return member.featuredImageThumbnail
            case .photographer:
                return member.photographer.photographerImage
            }
        }
    }

}
