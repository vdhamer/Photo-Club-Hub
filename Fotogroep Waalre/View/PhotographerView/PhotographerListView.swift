//
//  PhotographerListView.swift
//  Fotogroep Waalre 2
//
//  Created by Peter van den Hamer on 07/01/2022.
//

import SwiftUI

struct PhotographerListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingPhotoClubs = false
    @State private var showingMembers = false
    var searchText: Binding<String>

    @StateObject var model = SettingsViewModel()
    @EnvironmentObject var deviceOwner: DeviceOwner

    var body: some View {
        VStack {
            List { // lists are "Lazy" automatically
                Photographers(predicate: model.settings.photographerPredicate, searchText: searchText)
                Text("""
                     Information about a photographer's links to a photo club \
                     can be found on the Portfolio page. This page contains club-independent information \
                     such as a link to the photographer's own photography website.
                     """, comment: "Shown in gray at the bottom of the Photographers page.")
                    .foregroundColor(.gray)
            }
            .refreshable {
                FGWMembersProvider.foundAnOwner = false // for pull-to-refresh
                _ = FGWMembersProvider(fullOwnerName: deviceOwner.fullOwnerName)
            }
        }
        .keyboardType(.namePhonePad)
        .autocapitalization(.none)
        .submitLabel(.done) // currently only works with text fields?
        .searchable(text: searchText, placement: .automatic,
                    prompt: Text("Search names", comment:
                                 """
                                 Field at top of Photographers page that allows the user to \
                                 filter the photographers based on either given- and family name.
                                 """
                                 ))
        .disableAutocorrection(true)
        .navigationTitle(String(localized: "Who's who", comment: "Title of page with list of photographers"))
        .navigationViewStyle(StackNavigationViewStyle()) // avoids split screen on iPad
    }

}

struct PhotographerListView_Previews: PreviewProvider {
    @State static var searchText = ""
    static var previews: some View {
        PhotographerListView(searchText: $searchText)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
