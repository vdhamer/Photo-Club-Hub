//
//  PhotoClubView.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 07/01/2022.
//

import SwiftUI

struct PhotoClubsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingPhotographers = false
    @State private var showingMembers = false
    @EnvironmentObject var deviceOwner: DeviceOwner
    @StateObject var model = SettingsViewModel()

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.priority_, order: .reverse), // highest priority first
                          SortDescriptor(\.name_, order: .forward)],
        animation: .default)
    private var photoClubs: FetchedResults<PhotoClub>

    private let title = String(localized: "Photo Club Waalre", comment: "Title used in Navigation View")
    private var predicate: NSPredicate = NSPredicate.all

    init(predicate: NSPredicate) {
        self.predicate = predicate
    }

    init() {
        self.predicate = model.settings.photoClubPredicate // default value
    }

    var body: some View {
        VStack {
            List { // lists are "Lazy" automatically
                PhotoClubsInnerView(predicate: model.settings.photoClubPredicate)
            }
            .refreshable {
                FGWMembersProvider.foundAnOwner = false // for pull-to-refresh
                _ = FGWMembersProvider(fullOwnerName: deviceOwner.fullOwnerName)
                _ = BIMembersProvider()
                _ = TestMembersProvider()
            }
        }
        .navigationTitle(String(localized: "Photo clubs", comment: "Title of page with clubs and maps"))
        .navigationViewStyle(StackNavigationViewStyle()) // avoids split screen on iPad
    }

}

struct PhotoClubsView_Previews: PreviewProvider {
    static let predicate = NSPredicate(format: "name_ = %@ || name_ = %@ || name_ = %@",
                                       argumentArray: ["PhotoClub2", "PhotoClub1", "PhotoClub3"])

    static var previews: some View {
        NavigationView {
            List {
                PhotoClubsView(predicate: predicate)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
            .navigationBarTitle(Text(String("PhotoClubView"))) // prevent localization
        }
        .navigationViewStyle(.stack)
    }
}
