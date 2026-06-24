//
//  PhotographersListView2627.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/01/2022.
//

import SwiftUI
import CoreData
import WebKit // for wkWebView

// Implements entire Photographers screen including
//     * providing the navigation title,
//     * searchbar to filter on photographer's name,
//     * vertical (smart) scrolling photographer cards,
//     * help text at bottom. One of these footnotes shows the Expertise stats.
// See Preview below.

@available(iOS 26.0, *)
struct PhotographersListView2627: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingPhotoClubs = false
    @State private var showingMembers = false
    var searchText: Binding<String>
    let wkWebView: WKWebView

    @StateObject var model = PreferencesViewModel.shared
    private var navigationTitle = String(localized: "Photographers",
                                         table: "PhotoClubHub.SwiftUI",
                                         comment: "Title of page with list of photographers")
    private let temporary = String(localized: "Temporary",
                                   table: "PhotoClubHub.SwiftUI",
                                   comment: "Expertise description at bottom of Photographers screen")

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
                FilteredPhotographerView2627(predicate: model.preferences.photographerPredicate, // Here's the action
                                         searchText: searchText,
                                         wkWebView: wkWebView)
            }
            .scrollTargetLayout() // unit of vertical "smart" scrolling

            VStack(alignment: .leading) {
                Text("Photographers_Caption_1",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Shown in gray at the bottom of the Photographers page (1/4).")
                Divider()
                Text("Photographers_Caption_2",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Shown in gray at the bottom of the Photographers page (2/4).")
                Divider()
                Text("Photographers_Caption_3",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Shown in gray at the bottom of the Photographers page (3/4).")
                Divider()
                Text("Photographers_Caption_4",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Shown in gray at the bottom of the Photographers page (3/4).")
                ForEach(Expertise.getAll(context: viewContext)
                    .filter { !$0.id.contains("expertise") }  // Block "Too many expertises" entry
                    .sorted(by: sortExpertisesLocalized),
                        id: \.self) { expertise in
                    HStack {
                        Text(verbatim: """
                                       \(getIconString(isSupported: expertise.isSupported)) \
                                       \(expertise.selectedLocalizedExpertise().name)
                                       """)
                        Text(PhotographerExpertise.count(context: viewContext,
                                                         expertiseID: expertise.id).description+"x")
                        Text("\(expertise.isSupported ? "" : temporary)")
                    }
                }
                let totalCount = Expertise.count(context: viewContext)
                Text("There are \(totalCount) expertise tags.",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Expertise statistics in footnote #4 of Photographers screen")
                Text("""
                     \(totalCount
                     - Expertise.getAll(context: viewContext).filter { keyword in keyword.isSupported }.count) \
                     of these \(Expertise.count(context: viewContext)) \
                     expertise tags are temporary.
                     """,
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Expertise statistics in footnote #4 of Photographers screen")
                Text("Expertise tags were assigned \(PhotographerExpertise.count(context: viewContext)) times.",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Expertise statistics in footnote #4 of Photographers screen")
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
            Model.deleteCoreDataObjects(viewContext: viewContext, deletionScope: .all)
            PhotoClubHubApp.loadClubsAndMembers() // carefull: runs asynchronously
        }
        .keyboardType(.namePhonePad)
        .autocapitalization(.sentences)
        .submitLabel(.done) // currently only works with text fields?
        .navigationTitle(navigationTitle)
        .searchable(text: searchText, placement: searchPlacement,
                    prompt: Text("Search_names_p",
                                 tableName: "PhotoClubHub.SwiftUI",
                                 comment: """
                                          Field at top of Photographers page that allows the user to \
                                          filter the photographers based on either given- and family name.
                                          """)
        )
        .searchToolbarBehaviorIfAvailable()
        .disableAutocorrection(true)
    }

    private func sortExpertisesLocalized(lhs: Expertise, rhs: Expertise) -> Bool {
        return lhs.selectedLocalizedExpertise().name < rhs.selectedLocalizedExpertise().name
    }

    static let iconExamples = LocalizedExpertiseResultLists(supportedList: [], temporaryList: [])

    private func getIconString(isSupported: Bool) -> String {
        return isSupported ? Self.iconExamples.supported.icon : Self.iconExamples.temporary.icon
    }

}

// MARK: - Controlling search bar placement

/// On iOS 27, `.automatic` + `.minimize` adds a duplicate nav-bar icon.
/// While `.toolbar` + no `.minimize` suppresses it and gives the same single compact bottom button as iOS 26.
private var searchPlacement: SearchFieldPlacement {
    if #available(iOS 27, *) {
        return .toolbar
    } else {
        return .automatic
    }
}

@available(iOS 26.0, *)
private extension View {
    /// Applies `.searchToolbarBehavior(.minimize)` on iOS 26 only.
    /// On iOS 27+, `.minimize` adds a duplicate nav-bar icon on top of the compact bottom button;
    /// using `.toolbar` placement without `.minimize` reproduces the iOS 26 single-button behavior instead.
    @ViewBuilder
    func searchToolbarBehaviorIfAvailable() -> some View {
        if #available(iOS 27, *) {
            self
        } else {
            self.searchToolbarBehavior(.minimize)
        }
    }
}

// MARK: - Previews

// Believe it or not, the following Previews actually works.
@available(iOS 26.0, *)
#Preview {
    @Previewable @State var searchText = "D' Eau1"
    NavigationStack {
        PhotographersListView2627(searchText: $searchText)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
