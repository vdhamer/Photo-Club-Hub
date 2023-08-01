//
//  PhotoClubListView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/01/2022.
//

import SwiftUI

struct PhotoClubListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var model = PreferencesViewModel()

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.priority_, order: .reverse), // highest priority first
                          SortDescriptor(\.name_, order: .forward), // photo clubs are identified by (name, town)
                          SortDescriptor(\.town_, order: .forward)], // just to make it repeatable
        animation: .default)
    private var photoClubs: FetchedResults<PhotoClub>

    private var predicate: NSPredicate = NSPredicate.all
    private var navigationTitle = String(localized: "Photo Clubs", comment: "Title of page with clubs and maps")

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
        Group {
            List { // lists are "Lazy" automatically
                PhotoClubView(predicate: model.preferences.photoClubPredicate)
                if photoClubs.isEmpty {
                    NoClubsText()
                }
                Text("PhotoClubs_Caption", comment: "Shown in gray at the bottom of the Photo Club page.")
                    .foregroundColor(.gray)
            }
            .listStyle(.plain)
            .refreshable { // for pull-to-refresh
//                _ = FGWMembersProvider(bgContext: PersistenceController.shared.container.newBackgroundContext())
//                _ = BIMembersProvider(bgContext: PersistenceController.shared.container.newBackgroundContext())
//
//                _ = TestClubAmsterdamMembersProvider(bgContext:
//                                                     PersistenceController.shared.container.newBackgroundContext())
//                _ = TestClubDenHaagMembersProvider(bgContext:
//                                                     PersistenceController.shared.container.newBackgroundContext())
//                _ = TestClubRotterdamMembersProvider(bgContext:
//                                                     PersistenceController.shared.container.newBackgroundContext())
            } // TODO: uncomment
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
            PhotoClubListView(predicate: predicate, navigationTitle: String("PhotoClubView"))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
