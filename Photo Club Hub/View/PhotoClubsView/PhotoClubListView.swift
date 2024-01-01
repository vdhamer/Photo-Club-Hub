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
    @State var locationManager = LocationManager()

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.pinned, order: .reverse), // pinned club at top of list
                          SortDescriptor(\.name_, order: .forward), // photo clubs are identified by (name, town)
                          SortDescriptor(\.town_, order: .forward)], // just to make it repeatable
        animation: .default)
    private var photoClubs: FetchedResults<PhotoClub>
    private var predicate: NSPredicate = NSPredicate.all
    private var navigationTitle = String(localized: "Clubs", comment: "Title of page with maps of clubs and musea")

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
                Group {
                    Text("PhotoClubs_Caption_1", comment: "Shown in gray at the bottom of the Photo Club page (1/3).")
                    Text("PhotoClubs_Caption_2", comment: "Shown in gray at the bottom of the Photo Club page (2/3).")
                    // If the page has been force refreshed before then dim text of third item.
                    Text("PhotoClubs_Caption_3", comment: "Shown in gray at the bottom of the Photo Club page (3/3).")
                        .opacity(UserDefaults.standard.bool(forKey: "ClubListPageRefreshed") ? 0.3 : 1)
                } .foregroundColor(Color.primary)
            }
            .listStyle(.plain)
            .task {
                try? await locationManager.requestUserAuthorization()
                try? await locationManager.startCurrentLocationUpdates()
                // remember that nothing will run here until the for try await loop finishes
            }
            .refreshable { // for pull-to-refresh
                UserDefaults.standard.set(true, forKey: "ClubListPageRefreshed")

                // load test member(s) of Fotogroep Bellus Imago
                let biBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                biBackgroundContext.name = "Bellus Imago refresh"
                biBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                _ = BellusImagoMembersProvider(bgContext: biBackgroundContext)

                // load test member(s) of Fotogroep De Gender
//                let dgBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
//                dgBackgroundContext.name = "De Gender refresh"
//                dgBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
//                _ = FotogroepDeGenderMembersProvider(bgContext: dgBackgroundContext)

                // load all current members of Fotogroep Anders
//                let andersBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
//                andersBackgroundContext.name = "Anders refresh"
//                andersBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
//                _ = AndersMembersProvider(bgContext: andersBackgroundContext)

                // load all current/former members of Fotogroep Waalre
//                let fgwBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
//                fgwBackgroundContext.name = "Fotogroep Waalre refresh"
//                fgwBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
//                _ = FotogroepWaalreMembersProvider(bgContext: fgwBackgroundContext) TODO

                // load list of photo clubs from OrganizationList.json file
//                let olBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
//                olBackgroundContext.name = "ClubList refresh"
//                olBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
//                _ = OrganizationList(bgContext: olBackgroundContext) // read OrganizationList.json file TODO
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
