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
//     * help text at bottom. One of these footnotes shows the Expertise stats.
// Preview unfortunately doesn't work.

@available(iOS, obsoleted: 19.0, message: "Please use 'OrganizationListView2626' for versions above iOS 18.x")
struct WhoIsWhoListView1718: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingPhotoClubs = false
    @State private var showingMembers = false
    var searchText: Binding<String>
    let wkWebView: WKWebView

    @StateObject var model = PreferencesViewModel()
    private var navigationTitle = String(localized: "Who's Who",
                                         table: "PhotoClubHub.SwiftUI",
                                         comment: "Title of page with list of photographers")
    private let temporary = String(localized: "Temporary",
                                   table: "PhotoClubHub.SwiftUI",
                                   comment: "Expertise description at bottom of Who's Who screen")

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
                FilteredWhoIsWhoView1718(predicate: model.preferences.photographerPredicate,
                                         searchText: searchText,
                                         wkWebView: wkWebView)
            }
            .scrollTargetLayout() // unit of vertical "smart" scrolling

            VStack(alignment: .leading) {
                Text("WhosWho_Caption_1",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Shown in gray at the bottom of the Who's Who page (1/3).")
                Divider()
                Text("WhosWho_Caption_2",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Shown in gray at the bottom of the Who's Who page (2/3).")
                Divider()
                Text("WhosWho_Caption_3",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Shown in gray at the bottom of the Who's Who page (3/3).")
                Divider()
                Text("WhosWho_Caption_4",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Shown in gray at the bottom of the Who's Who page (3/3).")
                ForEach(Expertise.getAll(context: viewContext)
                    .filter { !$0.id.contains("expertise") }  // Block "Too many expertises" entry
                    .sorted(by: sortExpertisesLocalized),
                        id: \.self) { expertise in
                    HStack {
                        Text(verbatim: """
                                       \(getIconString(isSupported: expertise.isSupported)) \
                                       \(expertise.selectedLocalizedExpertise.name)
                                       """)
                        Text(PhotographerExpertise.count(context: viewContext,
                                                         expertiseID: expertise.id).description+"x")
                        Text("\(expertise.isSupported ? "" : temporary)")
                    }
                }
                let totalCount = Expertise.count(context: viewContext)
                Text("There are \(totalCount) expertise tags.",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Expertise statistics in footnote #4 of Who's Who screen")
                Text("""
                     \(totalCount
                     - Expertise.getAll(context: viewContext).filter { keyword in keyword.isSupported }.count) \
                     of these \(Expertise.count(context: viewContext)) \
                     expertise tags are temporary.
                     """,
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Expertise statistics in footnote #4 of Who's Who screen")
                Text("Expertise tags were assigned \(PhotographerExpertise.count(context: viewContext)) times.",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Expertise statistics in footnote #4 of Who's Who screen")
            }
            .foregroundColor(Color.secondary)

        } // ScrollView
        .padding(.horizontal)
        .scrollTargetBehavior(.viewAligned) // iOS 17 smart scrolling
        .contentMargins(.horizontal, -5, for: .scrollIndicators) // iOS 17 smart scrolling
        .refreshable { // for pull-to-refresh
            // do not remove next statement: a side-effect of reading the flag, is that it clears the flag!
            if Settings.dataResetPending {
                print("dataResetPending2 flag toggled from true to false")
            }
            Model.deleteAllCoreDataObjects(viewContext: viewContext)
            PhotoClubHubApp.loadClubsAndMembers() // carefull: runs asynchronously
        }
        .keyboardType(.namePhonePad)
        .autocapitalization(.sentences)
        .submitLabel(.done) // currently only works with text fields?
        .navigationTitle(navigationTitle)
        .searchable(text: searchText, placement: .automatic,
                    prompt: Text("Search_names_p",
                                 tableName: "PhotoClubHub.SwiftUI",
                                 comment: """
                                          Field at top of Who's Who page that allows the user to \
                                          filter the photographers based on either given- and family name.
                                          """)
        )
        .disableAutocorrection(true)
    }

    private func sortExpertisesLocalized(lhs: Expertise, rhs: Expertise) -> Bool {
        return lhs.selectedLocalizedExpertise.name < rhs.selectedLocalizedExpertise.name
    }

    static let iconExamples = LocalizedExpertiseResultLists(supportedList: [], temporaryList: [])

    private func getIconString(isSupported: Bool) -> String {
        return isSupported ? Self.iconExamples.supported.icon : Self.iconExamples.temporary.icon
    }

}

// struct PhotographersView_Previews: PreviewProvider {
//    @State static var searchText = "D'Eau1"
//    static var previews: some View {
//        NavigationStack {
//            WhoIsWhoListView(searchText: $searchText,
//                             organizationLabel: String("PhotographerListView")
//                )
//                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//        }
//    }
// }
