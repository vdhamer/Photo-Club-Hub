//
//  WhoIsWhoListView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/01/2022.
//

import SwiftUI
import CoreData
import WebKit // for wkWebView

// Implements entire Who's Who screen including
//     * providing the navigation title,
//     * searchbar to filter on photographer's name,
//     * vertical (smart) scrolling photographer cards,
//     * help text at bottom.
// Preview unfortunately doesn't work.

struct WhoIsWhoListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingPhotoClubs = false
    @State private var showingMembers = false
    var searchText: Binding<String>
    let wkWebView: WKWebView

    @StateObject var model = PreferencesViewModel()
    private var navigationTitle = String(localized: "Who's Who", comment: "Title of page with list of photographers")

    init(searchText: Binding<String>, navigationTitle: String? = nil) {
        self.searchText = searchText
        if let navigationTitle {
            self.navigationTitle = navigationTitle
        }
        self.wkWebView = WKWebView()
    }

    var body: some View {
        ScrollView(.vertical) {

            LazyVStack {
                FilteredWhoIsWhoView(predicate: model.preferences.photographerPredicate,
                                     searchText: searchText,
                                     wkWebView: wkWebView)
            }
            .scrollTargetLayout() // unit of vertical "smart" scrolling

            Group {
                Text("WhosWho_Caption_1",
                     comment: "Shown in gray at the bottom of the Who's Who page (1/3).")
                Text("WhosWho_Caption_2",
                     comment: "Shown in gray at the bottom of the Who's Who page (2/3).")
                Text("WhosWho_Caption_3",
                     comment: "Shown in gray at the bottom of the Who's Who page (3/3).")
            } .foregroundColor(Color.secondary)
            .padding(.top)

        } // ScrollView
        .padding(.horizontal)
        .scrollTargetBehavior(.viewAligned) // iOS 17 smart scrolling
        .refreshable { // for pull-to-refresh
            // UserDefaults.standard.set(true, forKey: "WhosWhoPageRefreshed") // not really used
            PhotoClubHubApp.loadClubsAndMembers()
        }
        .keyboardType(.namePhonePad)
        .autocapitalization(.none)
        .submitLabel(.done) // currently only works with text fields?
        .navigationTitle(navigationTitle)
        .searchable(text: searchText, placement: .automatic,
                    prompt: Text("Search_names_p",
                                 comment: """
                                          Field at top of Who's Who page that allows the user to \
                                          filter the photographers based on either given- and family name.
                                          """)
        )
        .disableAutocorrection(true)
    }

}

struct PhotographersView_Previews: PreviewProvider {
    @State static var searchText = "D'Eau1"
    static var previews: some View {
        NavigationStack {
            WhoIsWhoListView(searchText: $searchText,
                             navigationTitle: String("PhotographerListView")
                )
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
