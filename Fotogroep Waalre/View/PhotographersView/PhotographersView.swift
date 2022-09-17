//
//  PhotographersView.swift
//  Fotogroep Waalre 2
//
//  Created by Peter van den Hamer on 07/01/2022.
//

import SwiftUI

struct PhotographersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingPhotoClubs = false
    @State private var showingMembers = false
    var searchText: Binding<String>

    @StateObject var model = SettingsViewModel()
    private var navigationTitle = String(localized: "Who's who", comment: "Title of page with list of photographers")

    init(searchText: Binding<String>, navigationTitle: String? = nil) {
        self.searchText = searchText
        if let navigationTitle = navigationTitle {
            self.navigationTitle = navigationTitle
        }
    }

    var body: some View {
        VStack {
            List { // lists are "Lazy" automatically
                PhotographersInnerView(predicate: model.settings.photographerPredicate, searchText: searchText)
                Text("""
                     Information about a photographer's links to a photo club \
                     can be found on the Portfolio page. This page contains club-independent information \
                     such as a link to the photographer's own photography website.
                     """, comment: "Shown in gray at the bottom of the Photographers page.")
                    .foregroundColor(.gray)
            }
            .refreshable { // for pull-to-refresh
                _ = FGWMembersProvider()
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
        .navigationTitle(navigationTitle)
        .navigationViewStyle(StackNavigationViewStyle()) // avoids split screen on iPad
    }

}

struct PhotographersView_Previews: PreviewProvider {
    @State static var searchText = "D'Eau1"
    static var previews: some View {
        NavigationView {
                PhotographersView(searchText: $searchText,
                                  navigationTitle: String("PhotographerListView")
                )
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
        .navigationViewStyle(.stack)
    }
}
