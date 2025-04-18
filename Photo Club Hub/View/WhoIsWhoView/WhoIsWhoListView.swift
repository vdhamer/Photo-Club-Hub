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
    @Environment(\.managedObjectContext) fileprivate var viewContext
    @State fileprivate var showingPhotoClubs = false
    @State fileprivate var showingMembers = false
    var searchText: Binding<String>
    let wkWebView: WKWebView

    @StateObject var model = PreferencesViewModel()
    fileprivate var navigationTitle = String(localized: "Who's Who",
                                             comment: "Title of page with list of photographers")
    fileprivate let nonStandard = String(localized: "Non-standard",
                                      comment: "Keyword description at bottom of Who's Who screen")

    init(searchText: Binding<String>, navigationTitle: String? = nil) {
        self.searchText = searchText
        if let navigationTitle {
            self.navigationTitle = navigationTitle
        }
        self.wkWebView = WKWebView()
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {

            LazyVStack {
                FilteredWhoIsWhoView(predicate: model.preferences.photographerPredicate,
                                     searchText: searchText,
                                     wkWebView: wkWebView)
            }
            .scrollTargetLayout() // unit of vertical "smart" scrolling

            VStack(alignment: .leading) {
                Text("WhosWho_Caption_1",
                     comment: "Shown in gray at the bottom of the Who's Who page (1/3).")
                Divider()
                Text("WhosWho_Caption_2",
                     comment: "Shown in gray at the bottom of the Who's Who page (2/3).")
                Divider()
                Text("WhosWho_Caption_3",
                     comment: "Shown in gray at the bottom of the Who's Who page (3/3).")
                Divider()
                Text("WhosWho_Caption_4",
                     comment: "Shown in gray at the bottom of the Who's Who page (3/3).")
                ForEach(Keyword.getAll(context: viewContext), id: \.self) { keyword in
                    HStack {
                        Text(verbatim: "   🔑 \(keyword.id)")
                        Text(PhotographerKeyword.count(context: viewContext, keywordID: keyword.id).description+"x")
                        Text("\(keyword.isStandard ? "" : nonStandard)")
                    }
                }
                Text("Total number of Keyword instances: \(PhotographerKeyword.count(context: viewContext))x",
                     comment: "Keyword statistics at bottom of Who's Who screen")
                Text("Total number of Keywords: \(Keyword.count(context: viewContext))",
                     comment: "Keyword statistics at bottom of Who's Who screen")
            }
            .foregroundColor(Color.secondary)

        } // ScrollView
        .padding(.horizontal)
        .scrollTargetBehavior(.viewAligned) // iOS 17 smart scrolling
        .contentMargins(.horizontal, -5, for: .scrollIndicators) // iOS 17 smart scrolling
        .refreshable { // for pull-to-refresh
            // do not remove next statement: a side-effect of reading the flag, is that it clears the flag!
            if Settings.dataResetPending273 {
                print("dataResetPending273 flag reset from true to false")
            }
            Model.deleteAllCoreDataObjects(context: viewContext)
            PhotoClubHubApp.loadClubsAndMembers() // carefull: runs asynchronously
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
