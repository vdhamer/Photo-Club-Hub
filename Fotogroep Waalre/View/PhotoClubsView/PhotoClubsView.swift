//
//  PhotoClubView.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 07/01/2022.
//

import SwiftUI

struct PhotoClubsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var model = SettingsViewModel()

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.priority_, order: .reverse), // highest priority first
                          SortDescriptor(\.name_, order: .forward), // photo clubs are identified by (name, town)
                          SortDescriptor(\.town_, order: .forward)], // just to make it repeatable
        animation: .default)
    private var photoClubs: FetchedResults<PhotoClub>

    private let title = String(localized: "Photo Club Waalre", comment: "Title used in PhotoClubs View")
    private var predicate: NSPredicate = NSPredicate.all
    private var navigationTitle = String(localized: "Photo Clubs", comment: "Title of page with clubs and maps")

    init(predicate: NSPredicate? = nil,
         navigationTitle: String? = nil) {
        if predicate != nil {
            self.predicate = predicate!
        } else {
            self.predicate = model.settings.photoClubPredicate // dummy data for Preview
        }
        if let navigationTitle {
            self.navigationTitle = navigationTitle
        }
    }

    var body: some View {
        VStack {
            List { // lists are "Lazy" automatically
                PhotoClubsInnerView(predicate: model.settings.photoClubPredicate)
                Text("PhotoClubs_Caption", comment: "Shown in gray at the bottom of the Photo Club page.")
                    .foregroundColor(.gray)
            }
            .refreshable { // for pull-to-refresh
                _ = FGWMembersProvider()
                _ = BIMembersProvider()
                _ = TestClubRotterdamMembersProvider()
                _ = TestClubAmsterdamMembersProvider()
            }
        }
        .navigationTitle(navigationTitle)
    }

}

struct PhotoClubsView_Previews: PreviewProvider {
    static let predicate = NSPredicate(format: "name_ = %@ || name_ = %@ || name_ = %@",
                                       argumentArray: ["PhotoClub2", "PhotoClub1", "PhotoClub3"])

    static var previews: some View {
        NavigationStack {
            PhotoClubsView(predicate: predicate, navigationTitle: String("PhotoClubView"))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
