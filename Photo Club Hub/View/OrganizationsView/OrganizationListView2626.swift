//
//  OrganizationListView2626.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/01/2022.
//

import SwiftUI // for View
import CoreData // for NSPersistentContainer

@available(iOS 26.0, *)
struct OrganizationListView2626: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var model = PreferencesViewModel()
    @State private var locationManager = LocationManager()
    @State private var searchText: String = "" // bindable string with content of Search bar

    @FetchRequest(
        sortDescriptors: [], // organizations is only used for counting, so sorting doesn't matter
        animation: .default)
    private var organizations: FetchedResults<Organization>

    private static let predicateAll = NSPredicate(format: "TRUEPREDICATE")

    /// A localized title for the Organizations screen derived from user preferences.
    /// The`organizationLabel` is also used when displaying the count of shown organizations (e.g. "35 museums").
    ///
    /// This computed property inspects the current `PreferencesViewModel().preferences` flags
    /// — `showClubs`, `showTestClubs`, and `showMuseums` — to decide which section(s)
    /// of organizations are visible, and returns an appropriate, localized string.
    ///
    /// Logic overview:
    /// - If clubs (including test clubs) are shown and museums are hidden, returns "Clubs".
    /// - If only museums are shown, returns "Museums".
    /// - If nothing is shown, returns the neutral "Organizations".
    /// - In all mixed/combined cases (both clubs and museums visible), returns "Organizations".
    ///
    /// The returned value is localized using the "PhotoClubHub.SwiftUI" strings table.
    /// The returned value starts with a capital, so must be converted to lower case where needed.
    private var organizationLabel: String { // title depends on `showClubs`, `showTestClubs` and `showMuseums` settings
        let preferences = PreferencesViewModel().preferences
        let showClubs = preferences.showClubs
        let showTestClubs = preferences.showTestClubs
        let showMuseums = preferences.showMuseums

        if (showClubs || showTestClubs) && !showMuseums { // 3 out of 8 permulations
            return String(localized: "Clubs",
                          table: "PhotoClubHub.SwiftUI",
                          comment: "Title of page with maps for Clubs")
        }

        if !showClubs && !showTestClubs && showMuseums { // 1 out of 8 combinations
            return String(localized: "Museums",
                          table: "PhotoClubHub.SwiftUI",
                          comment: "Title of page with maps for Museums")
        }

        if !showClubs && !showTestClubs && !showMuseums { // 1 out of 8 combinations
            return String(localized: "Organizations",
                          table: "PhotoClubHub.SwiftUI",
                          comment: "Title of page with maps for Clubs and Museums")
        }

        // if (showClubs || showTestClubs) && showMuseums // 3 out of 8 combinations
        return String(localized: "Organizations",
                      table: "PhotoClubHub.SwiftUI",
                      comment: "Title of page with maps for Clubs and Museums")
    } // TODO move to another file

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {

            LazyVStack(alignment: .leading, spacing: 12) {
                FilteredOrganizationView2626(predicate: model.preferences.organizationPredicate,
                                             searchText: $searchText)
            }
            .scrollTargetLayout()

            if organizations.isEmpty {
                NoClubsText1718()
            }

            VStack(alignment: .leading) {
                Text("PhotoClubs_Caption_1",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Shown in gray at the bottom of the Clubs and Museums page (1/3).")
                Divider()
                Text("PhotoClubs_Caption_2",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Shown in gray at the bottom of the Clubs and Museums page (2/3).")
                Divider()
                Text("PhotoClubs_Caption_3",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Shown in gray at the bottom of the Clubs and Museums page (3/3).")
            }
            .foregroundColor(Color.secondary)
            .padding(.horizontal)
        } // ScrollView

        .scrollTargetBehavior(.viewAligned) // iOS 17 smart scrolling
        .refreshable { // for pull-to-refresh
            // do not remove next statement: a side-effect of reading the flag, is that it clears the flag!
            if Settings.dataResetPending {
                print("dataResetPending flag toggled from true to false")
            }
            Model.deleteAllCoreDataObjects(viewContext: viewContext)
            PhotoClubHubApp.loadClubsAndMembers() // carefull: runs asynchronously
        }
        .task { // will be aborted when ScrollView disappears
            try? await locationManager.requestUserAuthorization()
            try? await locationManager.startCurrentLocationUpdates()
            // remember that nothing will run here until the for try await loop finishes
        }
        .navigationTitle(organizationLabel)
        .searchable(text: $searchText, placement: .automatic,
                    // .automatic
                    // .toolbar The search field is placed in the toolbar. To right of person.text.rect.cust
                    // .sidebar The search field is placed in the sidebar of a navigation view. not on iPad
                    // .navigationBarDrawer The search field is placed in an drawer of the navigation bar. OK
                    prompt: Text("Search names and towns",
                                 tableName: "PhotoClubHub.SwiftUI",
                                 comment: """
                                          Field on the Clubs and Museums page that allows the user to \
                                          filter the members based on a fragment of the organization name or town.
                                          """
                                ))
        .searchToolbarBehavior(.minimize)
        .autocapitalization(.sentences)
        .disableAutocorrection(true)
    }

}

@available(iOS 26.0, *)
struct NoClubsText2626: View {
    var body: some View {
        Text("""
             No photo clubs or museums seem to be currently loaded.
             Try dragging down the Clubs and Museums screen to reload the default clubs.
             """,
             tableName: "PhotoClubHub.SwiftUI",
             comment: "Hint to the user if the database returns zero Organizations.")
    }
}

// previewing on Canvas doesn't work
@available(iOS 26.0, *)
struct PhotoClubListView2626_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            OrganizationListView2626()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
