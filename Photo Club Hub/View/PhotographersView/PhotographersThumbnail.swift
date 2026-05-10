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

    var body: some View {
        VStack { // to combine image and caption
            AsyncImage(url: ImageChoice(member: member,
                            isImageFlipped: flipImageFlag,
                            preferenceForFeaturedImage: preferences.preferenceForFeaturedImage).url) { phase in
                if let image = phase.image {
                    ZStack(alignment: .bottom) {
                        image // Displays the loaded image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160)
                    }
                } else if phase.error != nil ||
                            member.featuredImage == nil {
                    Image("Question-mark") // image indicates an error occurred
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    ZStack {
                        Image("Tortoise") // placeholder while loading
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(0.4)
                        ProgressView()
                            .scaleEffect(x: 2, y: 2, anchor: .center)
                            .blendMode(BlendMode.difference)
                    }
                }
            }
            .frame(width: 160, height: 160) // square
            .clipShape(RoundedRectangle(cornerRadius: 25))
            .shadow(color: .accentColor.opacity(0.5), radius: 3)
            .contentShape(Rectangle())
            .onTapGesture(perform: {
                if isThumbnailFlippable(member: member) {
                    flipImageFlag.toggle()
                }
            })

            SinglePortfolioLinkView(destPortfolio: member, wkWebView: wkWebView) {
                Text(verbatim: "\(member.roleDescriptionOfClubTown)")
                    .frame(width: 160, height: 35)
                    .font(.caption)
                    .lineLimit(2)
                    .truncationMode(.middle)
                    .dynamicTypeSize( // block xLarge (etc) dynamic type sizze for layout reasons
                        ...DynamicTypeSize.large)
            }
            .buttonStyle(.borderless)

        } // VStack to combine image and caption
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

#Preview("Single Portfolio Thumbnail (live data)") {
    let controller = PersistenceController.shared
    let context = controller.container.viewContext
    let wkWebView = WKWebView()
    let preferences = PreferencesViewModel.shared.preferences

    // Get first membership from live data
    let fetchRequest = MemberPortfolio.fetchRequest()
    let memberships = (try? context.fetch(fetchRequest)) ?? []

    if let member = memberships.first {
        VStack(spacing: 20) {
            Text(verbatim: "Portfolio for: \(member.photographer.fullNameFirstLast)")
                .font(.headline)
            Divider()

            PhotographersThumbnail(member: member, wkWebView: wkWebView, preferences: preferences)
                .border(Color.gray.opacity(0.3), width: 1)
        }
        .padding()
    } else {
        Text("No membership data available")
            .foregroundStyle(.secondary)
    }
}
