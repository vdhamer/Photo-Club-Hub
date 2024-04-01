//
//  WhoIsWhoListView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/01/2022.
//

import SwiftUI
import CoreData
import WebKit // for wkWebView

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
        VStack {
            List { // lists are automatically "Lazy"
                FilteredWhoIsWhoView(predicate: model.preferences.photographerPredicate,
                                     searchText: searchText,
                                     wkWebView: wkWebView)
                Text("""
                     This page lists all the photographers that this app knows about. \
                     A photographer has one or more clickable image thumbnails below the photographer's name. \
                     Clicking on any thumbnail leads to the images associated with one particular photo club. \
                     The thumbnails can be scrolled horizontally (if there are many of them on one line).
                     """, comment: "Shown in gray at the bottom of the Photographers page.")
                .foregroundColor(.gray)
            }
            .refreshable { // for pull-to-refresh
                // UserDefaults.standard.set(true, forKey: "WhosWhoPageRefreshed") // not really used
                PhotoClubHubApp.loadClubsAndMembers()
            }
        }
        .keyboardType(.namePhonePad)
        .autocapitalization(.none)
        .submitLabel(.done) // currently only works with text fields?
        .searchable(text: searchText, placement: .automatic,
                    prompt: Text("Search_names_p",
                                 comment: """
                                          Field at top of Who's Who page that allows the user to \
                                          filter the photographers based on either given- and family name.
                                          """)
        )
        .disableAutocorrection(true)
        .navigationTitle(navigationTitle)
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