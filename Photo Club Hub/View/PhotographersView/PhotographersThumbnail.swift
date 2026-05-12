//
//  PhotographersThumbnail.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/04/2024.
//

import SwiftUI // for View
import WebKit // for wkWebView
import CoreData // for NSFetchRequest

// Shows a single photographer portfolio thumbnail containing:
//     * image representing the portfolio
//     * role of photographer related to that photo club
//     * buttons (coming) to switch images, and to navigate to portfolio per club

struct PhotographersThumbnail: View {
    let member: MemberPortfolio // who is this about?
    let wkWebView: WKWebView // reusable WKWebView
    let preferences: PreferencesStruct
    /// `flipImageFlag` is flipped by tapping on image. It reverses the image to an alternative image.
    @State var flipImageFlag: Bool = false
    @StateObject var preferencesModel = PreferencesViewModel.shared

    var body: some View {
        HStack {
            DualImageWithCaptionAndControls(member: member,
                                            wkWebView: wkWebView,
                                            preferences: preferencesModel.preferences,
                                            squareSize: 160,
                                            caption: true,
                                            flipImageFlag: $flipImageFlag,
                                            preferenceForFeaturedImage:
                                                                preferencesModel.preferences.preferenceForFeaturedImage)
        }
    }

    private func isThumbnailFlippable(member: MemberPortfolio) -> Bool {
        return
            member.photographer.photographerImage != nil && // there are two images defined for this member
            member.photographer.photographerImage != member.featuredImage // and the two images are different
    }
}

// MARK: - Previews

// Helper (for previews only) to circumvent a Swift #Preview type-checking limitation.
// Believe it or not, these 3 previews actually work.
extension PhotographersThumbnail {

    static func makeFetchRequest(predicate: NSPredicate) -> NSFetchRequest<Photographer> {
        let fetchRequest = Photographer.fetchRequest()
        fetchRequest.predicate = predicate
        return fetchRequest
    }

}

// Believe it or not, these 3 previews actually work.
#Preview("Single Portfolio Thumbnail") {
    @Previewable @StateObject var preferencesModel = PreferencesViewModel()
    let controller = PersistenceController.preview
    let context = controller.container.viewContext
    let wkWebView = WKWebView()
    let preferences = preferencesModel.preferences

    // Get first membership from preview data
    let fetchRequest = MemberPortfolio.fetchRequest()
    let memberships = (try? context.fetch(fetchRequest)) ?? []

    if let membership = memberships.first {
        VStack(spacing: 20) {
            Text(verbatim: "Portfolio for: \(membership.photographer.fullNameFirstLast)")
                .font(.headline)
            Divider()

            PhotographersThumbnail(member: membership, wkWebView: wkWebView, preferences: preferences)
                .border(Color.gray.opacity(0.3), width: 1)
        }
        .padding()
    } else {
        Text("No membership data available")
            .foregroundStyle(.secondary)
    }
}
