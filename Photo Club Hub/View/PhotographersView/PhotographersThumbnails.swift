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
//     * role of photographer related to that photo club
//     * buttons (coming) to switch images, and to navigate to portfolio per club

struct PhotographersThumbnails: View {
    let photographer: Photographer // who is this about?
    let wkWebView: WKWebView // reusable WKWebView
    @StateObject var preferencesModel = PreferencesViewModel.shared

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) { // 2nd row with images in photographer's "card"
            HStack { // to support multiple portfolio previews in one row
                ForEach(photographer.memberships.sorted(), id: \.id) { membership in
                    PhotographersThumbnail(member: membership,
                                           wkWebView: wkWebView,
                                           preferences: preferencesModel.preferences)
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

// MARK: - Previews

// Believe it or not, these 3 previews actually work.
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
                Divider()

                PhotographersThumbnails(photographer: photographer, wkWebView: wkWebView)
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

// Believe it or not, these 3 previews actually work.
#Preview("Photographer with Multiple Memberships (live data)") {
    let wkWebView = WKWebView()
    let controller = PersistenceController.shared
    let context = controller.container.viewContext

    // Get first photographer from live data (should have memberships)
    let personName = PersonName(givenName: "Peter", infixName: "van den", familyName: "Hamer")
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

                PhotographersThumbnails(photographer: photographer, wkWebView: wkWebView)
                    .border(Color.gray.opacity(0.7), width: 1)

                Text(verbatim: "Preview: Horizontal scrolling thumbnails")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    } else {
        Text(verbatim: "No photographer data available")
            .foregroundStyle(.secondary)
    }
}
