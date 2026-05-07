//
//  PhotographersThumbnails.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/04/2024.
//

import SwiftUI // for View
import WebKit // for wkWebView
import CoreData // for NSFetchRequest

// Shows horizontally scrolling thumbnails (normally 1 or 2) for photographer portfolios, each containing:
//     * image representing the portfolio
//     * role of protographer related to that photo club
// No preview because it didn't work.

struct PhotographersThumbnails: View {
    var photographer: Photographer // who is this about?
    var wkWebView: WKWebView // reusable WKWebView

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) { // 2nd row with images in photographer's "card"
            HStack { // to support multiple portfolio previews in one row
                ForEach(photographer.memberships.sorted(), id: \.id) { membership in
                    SinglePortfolioLinkView(destPortfolio: membership, wkWebView: wkWebView) {
                        PhotographersThumbnail(membership: membership, wkWebView: wkWebView)
                    } // SinglePortfolioLinkView
                } // ForEach
            } // HStack to support multiple portfolio previews in one row
            .scrollTargetLayout() // unit of horizontal "smart" scrolling, iOS smart scrolling
        } // ScrollView
        .contentMargins(.horizontal, 43, for: .scrollContent) // iOS 17 smart scrolling
        .contentMargins(.horizontal, 43, for: .scrollIndicators) // iOS 17 smart scrolling
        .contentMargins(.vertical, 10, for: .scrollContent) // iOS 17 smart scrolling
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always)) // iOS 17 smart scrolling
    }
}

// Shows hor scrolling thumbnails (normally 1 or 2) for photographer portfolios, each containing:
//     * image representing the portfolio
//     * role of protographer related to that photo club
// No preview because it didn't work.

struct PhotographersThumbnail: View {
    var membership: MemberPortfolio // who is this about?
    var wkWebView: WKWebView // reusable WKWebView

    var body: some View {
        VStack { // to combine image and caption
            AsyncImage(url: membership.featuredImage) { phase in
                if let image = phase.image {
                    ZStack(alignment: .bottom) {
                        image // Displays the loaded image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 160)
                    }
                } else if phase.error != nil ||
                            membership.featuredImage == nil {
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

            Text(verbatim: "\(membership.roleDescriptionOfClubTown)")
                .frame(width: 160, height: 35)
                .font(.caption)
                .lineLimit(2)
                .truncationMode(.middle)
                .dynamicTypeSize( // block xLarge (etc) dynamic type sizze for layout reasons
                    ...DynamicTypeSize.large)
        } // VStack to combine image and caption
    }
}

// MARK: - Previews

// Believe it or not, these 3 previews actually works.
#Preview("Single Portfolio Thumbnail") {
    let controller = PersistenceController.preview
    let context = controller.container.viewContext
    let wkWebView = WKWebView()

    // Get first membership from preview data
    let fetchRequest = MemberPortfolio.fetchRequest()
    let memberships = (try? context.fetch(fetchRequest)) ?? []

    if let membership = memberships.first {
        VStack(spacing: 20) {
            Text(verbatim: "Portfolio for: \(membership.photographer.fullNameFirstLast)")
                .font(.headline)
            Divider()

            PhotographersThumbnail(membership: membership, wkWebView: wkWebView)
                .border(Color.gray.opacity(0.3), width: 1)
        }
        .padding()
    } else {
        Text("No membership data available")
            .foregroundStyle(.secondary)
    }
}

/// function (for preview only) is used to circumvent a limitation of #Preview that resulting in type checking error
extension PhotographersThumbnail {

    fileprivate static func makeFetchRequest(predicate: NSPredicate) -> NSFetchRequest<Photographer> {
        let fetchRequest = Photographer.fetchRequest()
        fetchRequest.predicate = predicate
        return fetchRequest
    }

}

#Preview("Photographer with Multiple Memberships") {
    let wkWebView = WKWebView()
    let controller = PersistenceController.preview
    let context = controller.container.viewContext

    // Get first photographer from preview data (should have memberships)
    let personName = PersonName(givenName: "Jan", infixName: "D'", familyName: "Eau1")
    let predicateFormat: String = "givenName_ = %@ AND infixName_ = %@ AND familyName_ = %@" // avoid localization
    let predicate = NSPredicate(format: predicateFormat,
                                argumentArray: [ personName.givenName, personName.infixName, personName.familyName ])
    let fetchRequest = PhotographersThumbnail.makeFetchRequest(predicate: predicate)

    let photographers: [Photographer] = (try? context.fetch(fetchRequest)) ?? [] // nil means absolute failure

    if let photographer = photographers.first {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(verbatim: "Photographer: \(photographer.fullNameFirstLast)")
                    .font(.headline)

                PhotographersThumbnails(photographer: photographer, wkWebView: wkWebView) // wkWebView needed?
                    .border(Color.gray.opacity(0.7), width: 1)

                Divider()
                HStack {
                    Spacer()
                    Text(verbatim: "Preview: Horizontal scrolling thumbnails")
                        .font(.caption)
                        .italic()
                        .foregroundStyle(.secondary)
                    Spacer()
                }

            }
            .padding()
        }
        .border(Color.gray.opacity(0.7), width: 1)
    } else {
        Text(verbatim: "No photographer data available")
            .foregroundStyle(.secondary)
            .border(Color.gray.opacity(0.7), width: 1)
    }
}
