//
//  OrganizationListView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/01/2022.
//

import SwiftUI
import CoreData // for implementing .refreshable

struct OrganizationListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var model = PreferencesViewModel()
    @State var locationManager = LocationManager()
    @FetchRequest(
        sortDescriptors: [], // organizations is only used for counting, so sorting doesn't matter
        animation: .default)
    private var organizations: FetchedResults<Organization>
    private var predicate: NSPredicate = NSPredicate.all
    private var navigationTitle = String(localized: "Clubs and Museums",
                                         comment: "Title of page with club and museum maps")

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
        VStack {
            List { // lists are "Lazy" automatically
                HStack {
                    Spacer() // allign to right
                    Text("\(organizations.count) entries",
                         comment: "number of records displayed at top of Clubs screen")
                        .textCase(.lowercase) // otherwise becomes CAPITALIZED for some reason
                }
                OrganizationView(predicate: model.preferences.photoClubPredicate)
                if organizations.isEmpty {
                    NoClubsText()
                }
                Group {
                    Text("PhotoClubs_Caption_1", comment: "Shown in gray at the bottom of the Photo Club page (1/3).")
                    Text("PhotoClubs_Caption_2", comment: "Shown in gray at the bottom of the Photo Club page (2/3).")
                } .foregroundColor(Color.primary)
            }
            .listStyle(.plain)
            .task {
                try? await locationManager.requestUserAuthorization()
                try? await locationManager.startCurrentLocationUpdates()
                // remember that nothing will run here until the for try await loop finishes
            }
            .refreshable { // for pull-to-refresh
                PhotoClubHubApp.loadClubsAndMembers()
            }
        }
        .navigationTitle(navigationTitle)
    }

}

struct NoClubsText: View {
    var body: some View {
        Text("""
             No photo clubs seem to be currently loaded.
             Try dragging down the Photo Clubs screen to reload the default clubs.
             """, comment: "Hint to the user if the database returns zero PhotoClubs.")
    }
}

struct PhotoClubListView_Previews: PreviewProvider {
    static let predicate = NSPredicate(format: "name_ = %@ || name_ = %@ || name_ = %@",
                                       argumentArray: ["PhotoClub2", "PhotoClub1", "PhotoClub3"])

    static var previews: some View {
        NavigationStack {
            OrganizationListView(predicate: predicate, navigationTitle: String("PhotoClubView"))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
