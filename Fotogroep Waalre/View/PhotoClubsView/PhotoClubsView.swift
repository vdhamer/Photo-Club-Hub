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
                          SortDescriptor(\.name_, order: .forward)],
        animation: .default)
    private var photoClubs: FetchedResults<PhotoClub>

    private let title = String(localized: "Photo Club Waalre", comment: "Title used in PhotoClubs View")
    private var predicate: NSPredicate = NSPredicate.all
    private var navigationTitle = String(localized: "Photo clubs", comment: "Title of page with clubs and maps")

    init(predicate: NSPredicate? = nil,
         navigationTitle: String? = nil) {
        if predicate != nil {
            self.predicate = predicate!
        } else {
            self.predicate = model.settings.photoClubPredicate // dummy data for Preview
        }
        if let navigationTitle = navigationTitle {
            self.navigationTitle = navigationTitle
        }
    }

    var body: some View {
        VStack {
            List { // lists are "Lazy" automatically
                PhotoClubsInnerView(predicate: model.settings.photoClubPredicate)
            }
            .refreshable { // for pull-to-refresh
                _ = FGWMembersProvider()
                _ = BIMembersProvider()
                _ = TestMembersProvider()
            }
        }
        .navigationTitle(navigationTitle)
        .navigationViewStyle(StackNavigationViewStyle()) // avoids split screen on iPad
    }

}

struct PhotoClubsView_Previews: PreviewProvider {
    static let predicate = NSPredicate(format: "name_ = %@ || name_ = %@ || name_ = %@",
                                       argumentArray: ["PhotoClub2", "PhotoClub1", "PhotoClub3"])

    static var previews: some View {
        NavigationView {
            PhotoClubsView(predicate: predicate, navigationTitle: String("PhotoClubView"))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
        .navigationViewStyle(.stack)
    }
}
