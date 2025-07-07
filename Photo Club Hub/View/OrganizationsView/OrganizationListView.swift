//
//  OrganizationListView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/01/2022.
//

import SwiftUI

struct OrganizationListView: View {
    @Environment(\.managedObjectContext) fileprivate var viewContext
    @StateObject var model = PreferencesViewModel()
    @State var locationManager = LocationManager()
    @State fileprivate var searchText: String = "" // bindable string with content of Search bar

    @FetchRequest(
        sortDescriptors: [], // organizations is only used for counting, so sorting doesn't matter
        animation: .default)
    fileprivate var organizations: FetchedResults<Organization>

    fileprivate static let predicateAll = NSPredicate(format: "TRUEPREDICATE")
    fileprivate var predicate: NSPredicate = Self.predicateAll
    fileprivate var navigationTitle = String(localized: "Clubs and Museums",
                                             comment: "Title of page with maps for Clubs and Museums")

    init(predicate: NSPredicate? = nil,
         navigationTitle: String? = nil) {
        if predicate != nil {
            self.predicate = predicate!
        } else {
            self.predicate = model.preferences.photoClubPredicate // dummy data for Preview
        }
        if let navigationTitle {
            self.navigationTitle = navigationTitle
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {

            LazyVStack {
                FilteredOrganizationView(predicate: model.preferences.photoClubPredicate, searchText: $searchText)
            }
            .scrollTargetLayout()

            if organizations.isEmpty {
                NoClubsText()
            }

            VStack(alignment: .leading) {
                Text("PhotoClubs_Caption_1",
                     comment: "Shown in gray at the bottom of the Clubs and Museums page (1/3).")
                Divider()
                Text("PhotoClubs_Caption_2",
                     comment: "Shown in gray at the bottom of the Clubs and Museums page (2/3).")
                Divider()
                Text("PhotoClubs_Caption_3",
                     comment: "Shown in gray at the bottom of the Clubs and Museums page (3/3).")
            }
            .foregroundColor(Color.secondary)
            .padding(.horizontal)
        } // ScrollView

        .scrollTargetBehavior(.viewAligned) // iOS 17 smart scrolling
        .refreshable { // for pull-to-refresh
            // do not remove next statement: a side-effect of reading the flag, is that it clears the flag!
            if Settings.dataResetPending280b4644 {
                print("dataResetPending280 flag reset from true to false")
            }
            Model.deleteAllCoreDataObjects(context: viewContext)
            PhotoClubHubApp.loadClubsAndMembers() // carefull: runs asynchronously
        }
        .task { // will be aborted when ScrollView disappears
            try? await locationManager.requestUserAuthorization()
            try? await locationManager.startCurrentLocationUpdates()
            // remember that nothing will run here until the for try await loop finishes
        }
        .navigationTitle(navigationTitle)
        .searchable(text: $searchText, placement: .automatic,
                    // .automatic
                    // .toolbar The search field is placed in the toolbar. To right of person.text.rect.cust
                    // .sidebar The search field is placed in the sidebar of a navigation view. not on iPad
                    // .navigationBarDrawer The search field is placed in an drawer of the navigation bar. OK
                    prompt: Text("Search names and towns", comment:
                                    """
                                    Field at top of Clubs and Museums page that allows the user to \
                                    filter the members based on a fragment of the organization name.
                                    """
                                ))
        .disableAutocorrection(true)
    }

    fileprivate let toolbarItemPlacement: ToolbarItemPlacement = UIDevice.isIPad ?
        .destructiveAction : // iPad: Search field in toolbar
        .navigationBarTrailing // iPhone: Search field in drawer
}

struct NoClubsText: View {
    var body: some View {
        Text("""
             No photo clubs seem to be currently loaded.
             Try dragging down the Clubs and Museums screen to reload the default clubs.
             """, comment: "Hint to the user if the database returns zero PhotoClubs.")
    }
}

struct PhotoClubListView_Previews: PreviewProvider {
    static let predicate = NSPredicate(format: "fullName_ = %@ || fullName_ = %@ || fullName_ = %@",
                                       argumentArray: ["PhotoClub2", "PhotoClub1", "PhotoClub3"])

    static var previews: some View {
        NavigationStack {
            OrganizationListView(predicate: predicate, navigationTitle: String("PhotoClubView"))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
