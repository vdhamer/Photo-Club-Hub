//
//  PhotographersThumbnail.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/04/2024.
//

import SwiftUI // for View
import CoreData // for NSFetchRequest

// Shows a single photographer portfolio thumbnail containing:
//     * image representing the portfolio
//     * role of photographer related to that photo club
//     * buttons (coming) to switch images, and to navigate to portfolio per club

struct PhotographersThumbnail: View {
    @ObservedObject var member: MemberPortfolio // who is this about?
    let settings: SettingsStruct
    /// Set by tapping the caption or chevron; the screen-level view owns the navigationDestination(item:).
    /// Navigation destinations may not be declared inside lazy containers (List rows, LazyVStack).
    @Binding var selectedPortfolio: MemberPortfolio?
    /// `flipImageFlag` is flipped by tapping on image. It reverses the image to an alternative image.
    @State var flipImageFlag: Bool = false

    var body: some View {
        HStack {
            DualImageWithCaptionAndControls(member: member,
                                            settings: settings,
                                            squareSize: 160,
                                            caption: true,
                                            flipImageFlag: $flipImageFlag,
                                            selectedPortfolio: $selectedPortfolio)
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
    @Previewable @StateObject var settingsModel = SettingsViewModel()
    @Previewable @State var selectedPortfolio: MemberPortfolio?
    let controller = PersistenceController.preview
    let context = controller.container.viewContext
    let settings = settingsModel.settings

    // Get first membership from preview data
    let fetchRequest = MemberPortfolio.fetchRequest()
    let memberships = (try? context.fetch(fetchRequest)) ?? []

    if let membership = memberships.first {
        VStack(spacing: 20) {
            Text(verbatim: "Portfolio for: \(membership.photographer.fullNameFirstLast)")
                .font(.headline)
            Divider()

            PhotographersThumbnail(member: membership,
                                   settings: settings,
                                   selectedPortfolio: $selectedPortfolio)
                .border(Color.gray.opacity(0.3), width: 1)
        }
        .padding()
    } else {
        Text("No membership data available")
            .foregroundStyle(.secondary)
    }
}
