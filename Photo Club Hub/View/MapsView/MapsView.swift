//
//  MapsView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/01/2022.
//

import CoreData // for NSManagedObjectContext, FetchRequest
import SwiftUI // for View

/// A scroll-based view that displays photo clubs and museums with maps and markers showing their locations.
///
/// - Presents a `FilteredOrganizationView` inside a SwiftUI `ScrollView` with a `LazyVStack`.
/// - Shows a fallback `NoClubsText` hint when no organizations (= clubs or museums) are loaded.
/// - Supports pull-to-refresh to delete and then reimport Core Data entities.
/// - Requests location authorization (once) and starts location updates while the view is visible.
///
struct MapsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    /// A wrapper that mainly holds a Preferences struct
    @StateObject var modelToHoldSettings = SettingsViewModel.shared
    @State private var searchText: String = ""
    @State private var isSearchPresented = false
    /// Tracks user location to enable the user-location annotation on the map.
    @State private var locationManager = LocationManager()

    /// Organizations fetched only to detect the empty state; sorting is irrelevant for counting.
    @FetchRequest(
        sortDescriptors: [], // organizations is only used for counting, so sorting doesn't matter
        animation: .default)
    private var organizations: FetchedResults<Organization>

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {

            LazyVStack(alignment: .leading, spacing: 12) {
                /// This is where the List of Photographers is generated.
                /// So the most relevant stuff happens in FilteredMapsView
                FilteredMapsView(
                    predicate: modelToHoldSettings.settings.organizationPredicate,
                    searchText: $searchText)
            }
            .scrollTargetLayout()

            if organizations.isEmpty {
                NoClubsText()
            }

            VStack(alignment: .leading) {
                Text("Organizations_Caption_1",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Shown in gray at the bottom of the Organizations page (1/3).")
                Divider()
                Text("Organizations_Caption_2",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Shown in gray at the bottom of the Organizations page (2/3).")
                Divider()
                Text("Organizations_Caption_3",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Shown in gray at the bottom of the Organizations page (3/3).")
            }
            .foregroundColor(Color.secondary)
            .padding(.horizontal)
        } // ScrollView

        .scrollTargetBehavior(.viewAligned) // iOS 17 smart scrolling
        .searchable(text: $searchText,
                    isPresented: $isSearchPresented,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: String(localized: "Search prompt maps",
                                   table: "PhotoClubHub.SwiftUI",
                                   bundle: Bundle.main,
                                   comment: """
                                            Field on the Organizations page that allows the user to filter the members \
                                            based on a fragment of the organization name or town.
                                            """))
        .refreshable { // for pull-to-refresh
            // Pull-to-refresh: clears pending reset flag, wipes Core Data, and reloads data.
            // do not remove next statement: a side-effect of reading the flag, is that it clears the flag!
            if Settings.dataResetPending {
                print("dataResetPending flag toggled from true to false")
            }
            Model.deleteCoreDataObjects(viewContext: viewContext, deletionScope: .all)
            PhotoClubHubApp.loadClubsAndMembers() // carefull: runs asynchronously
        }
        .task { // will be aborted when ScrollView disappears
            // Request location authorization and start updates; aborted when ScrollView disappears.
            try? await locationManager.requestUserAuthorization()
            try? await locationManager.startCurrentLocationUpdates()
            // remember that nothing will run here until the for try await loop finishes
        }
        .navigationTitle(modelToHoldSettings.settings.organizationLabel())
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ReadmeButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { isSearchPresented = true } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
        .autocapitalization(.sentences)
        .disableAutocorrection(true)
    }

}

/// Fallback hint displayed when the database returns zero organizations,
/// instructing the user to pull down to reload the default clubs.
struct NoClubsText: View {
    var body: some View {
        Text("""
             No photo clubs or museums seem to be currently loaded.
             Try dragging down the Organizations screen to reload the default clubs.
             """,
             tableName: "PhotoClubHub.SwiftUI",
             comment: "Hint to the user if the database returns zero Organizations.")
    }
}

// MARK: - Previews

// Believe it or not, the following Preview actually works.
#Preview {
    NavigationStack {
        MapsView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
