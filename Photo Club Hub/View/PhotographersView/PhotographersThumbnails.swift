//
//  PhotographersThumbnails.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/04/2024.
//

import SwiftUI // for View
import CoreData // for NSFetchRequest

// Shows horizontally scrolling thumbnails (normally 1 or 2) for photographer portfolios, each containing:
//     * image representing the portfolio
//     * role of photographer related to that photo club
//     * buttons (coming) to switch images, and to navigate to portfolio per club

struct PhotographersThumbnails: View {
    let photographer: Photographer // who is this about?
    /// Set by tapping a caption or chevron; the screen-level view owns the navigationDestination(item:).
    /// Navigation destinations may not be declared inside lazy containers (List rows, LazyVStack).
    @Binding var selectedPortfolio: MemberPortfolio?
    @StateObject var settingsModel = SettingsViewModel.shared

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) { // 2nd row with images in photographer's "card"
            HStack { // to support multiple portfolio previews in one row
                ForEach(photographer.memberships.sorted(), id: \.id) { membership in
                    PhotographersThumbnail(member: membership,
                                           settings: settingsModel.settings,
                                           selectedPortfolio: $selectedPortfolio)
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

// Believe it or not, these 2 previews actually work.

#Preview("Photographer with Multiple Memberships") {
    @Previewable @State var selectedPortfolio: MemberPortfolio?
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

                PhotographersThumbnails(photographer: photographer,
                                        selectedPortfolio: $selectedPortfolio)
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

#Preview("Photographer with Multiple Memberships (live data)") {
    @Previewable @State var selectedPortfolio: MemberPortfolio?
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

                PhotographersThumbnails(photographer: photographer,
                                        selectedPortfolio: $selectedPortfolio)
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
