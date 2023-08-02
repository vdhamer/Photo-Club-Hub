//
//  PhotoClubListView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/01/2022.
//

import SwiftUI
import CoreData // for implementing .refreshable

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
                let biBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                biBackgroundContext.name = "Bellus Imago refresh"
                biBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                _ = BellusImagoMembersProvider(bgContext: biBackgroundContext)

                // load all current/former members of Fotogroep Waalre
                let fgwBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                fgwBackgroundContext.name = "Fotogroep Waalre refresh"
                fgwBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                _ = FotogroepWaalreMembersProvider(bgContext: fgwBackgroundContext)

                // Load a few test members for 3 non-existent photo clubs.
                // But this also tests support for clubs with same name in different towns
                let taBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                taBackgroundContext.name = "Amsterdam refresh"
                taBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                _ = TestClubAmsterdamMembersProvider(bgContext: taBackgroundContext)

                let tdBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                tdBackgroundContext.name = "Den Haag refresh"
                tdBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                _ = TestClubDenHaagMembersProvider(bgContext: tdBackgroundContext)

                let trBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                trBackgroundContext.name = "Rotterdam refresh"
                trBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                _ = TestClubRotterdamMembersProvider(bgContext: trBackgroundContext)
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
            PhotoClubListView(predicate: predicate, navigationTitle: String("PhotoClubView"))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
