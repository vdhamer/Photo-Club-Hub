//
//  OrganizationListView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/01/2022.
//

import SwiftUI // for View

/// A scroll-based view that displays photo clubs and museums with a search field
/// and maps with markers showing club/museum locations.
///
/// - Presents a `FilteredOrganizationView` inside a SwiftUI `ScrollView` with a `LazyVStack`.
/// - Shows a fallback `NoClubsText` hint when no organizations (= clubs or museums) are loaded.
/// - Supports pull-to-refresh to delete and then reimport Core Data entities.
/// - Requests location authorization (once) and starts location updates while the view is visible.
/// - Uses a search field to filter organizations by name or town.
///
/// The code has one location where the code for iOS 27 and iOS 17/18 deviate from each other.
///
struct OrganizationView: View {
    @Environment(\.managedObjectContext) private var viewContext

    /// A wrapper that mainly holds a Preferences struct
    @StateObject var modelToHoldPreferences = PreferencesViewModel()
    /// Tracks user location to enable the user-location annotation on the map.
    @State private var locationManager = LocationManager()
    /// The text bound to the search field used to filter organizations by name or town.
    @State private var searchText: String = "" // bindable String

    /// Organizations fetched only to detect the empty state; sorting is irrelevant for counting.
    @FetchRequest(
        sortDescriptors: [], // organizations is only used for counting, so sorting doesn't matter
        animation: .default)
    private var organizations: FetchedResults<Organization>

    private static let predicateAll = NSPredicate(format: "TRUEPREDICATE")

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {

            LazyVStack(alignment: .leading, spacing: 12) {
                /// This is where the List of Photographers is generated.
                /// So the most relevant stuff happens in FilteredOrganizationView
                if #available(iOS 26.0, *) {
                    FilteredOrganizationView2626(
                        predicate: modelToHoldPreferences.preferences.organizationPredicate,
                        searchText: $searchText)
                } else {
                    FilteredOrganizationView1718(
                        predicate: modelToHoldPreferences.preferences.organizationPredicate,
                        searchText: $searchText)
                }
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
        .refreshable { // for pull-to-refresh
            // Pull-to-refresh: clears pending reset flag, wipes Core Data, and reloads data.
            // do not remove next statement: a side-effect of reading the flag, is that it clears the flag!
            if Settings.dataResetPending {
                print("dataResetPending flag toggled from true to false")
            }
            Model.deleteAllCoreDataObjects(viewContext: viewContext)
            PhotoClubHubApp.loadClubsAndMembers() // carefull: runs asynchronously
        }
        .task { // will be aborted when ScrollView disappears
            // Request location authorization and start updates; aborted when ScrollView disappears.
            try? await locationManager.requestUserAuthorization()
            try? await locationManager.startCurrentLocationUpdates()
            // remember that nothing will run here until the for try await loop finishes
        }
        .navigationTitle(PreferencesViewModel().preferences.organizationLabel()) // trick: Published+UserDefaults.swift
        .searchable(text: $searchText, placement: .automatic,
                    // .automatic
                    // .toolbar The search field is placed in the toolbar. To right of person.text.rect.cust
                    // .sidebar The search field is placed in the sidebar of a navigation view. not on iPad
                    // .navigationBarDrawer The search field is placed in an drawer of the navigation bar. OK
                    prompt: Text("Search names and towns",
                                 tableName: "PhotoClubHub.SwiftUI",
                                 comment: """
                                          Field on the Organizations page that allows the user to \
                                          filter the members based on a fragment of the organization name or town.
                                          """
                                ))
        // .searchToolbarBehavior(.minimize) // requires iOS 26+
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

/// This preview doesn't work yet
#Preview {
    NavigationStack {
        OrganizationView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
