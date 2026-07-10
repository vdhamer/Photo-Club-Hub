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
    @Environment(\.horizontalSizeClass) private var horSizeClass
    @State private var showingPhotoClubs = false
    @State private var showingMembers = false
    /// The member whose portfolio is shown; setting it (from a thumbnail) triggers navigation via
    /// `navigationDestination(item:)`. Registered here because destinations may not live inside a lazy LazyVStack.
    @State private var selectedPortfolio: MemberPortfolio?
    var searchText: Binding<String>
    @State private var isSearchPresented = false
    /// Single instance shared by all thumbnails and the portfolio destination to avoid repeated WKWebView allocation.
    /// Stored in @State so it survives re-initialization of this view struct.
    @State private var wkWebView = WKWebView()

    @StateObject var model = SettingsViewModel.shared
    private var navigationTitle = String(localized: "People",
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
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {

            LazyVStack {
                FilteredPhotographerView2627(predicate: model.settings.photographerPredicate, // Here's the action
                                         searchText: searchText,
                                         wkWebView: wkWebView,
                                         selectedPortfolio: $selectedPortfolio)
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
        .animation(.default, value: searchText.wrappedValue) // cards fade in/out as the Search text changes
        .searchable(text: searchText,
                    isPresented: $isSearchPresented,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: String(localized: "Search prompt people",
                                   table: "PhotoClubHub.SwiftUI",
                                   bundle: Bundle.main,
                                   comment: """
                                            Field at top of Photographers page that allows the user to filter the \
                                            photographers based on either given- and family name.
                                            """))
        .navigationDestination(item: $selectedPortfolio) { member in
            SinglePortfolioView(url: member.level3URL, webView: wkWebView)
                .navigationTitle(member.photographer.fullNameFirstLast + " @ " +
                                 (horSizeClass == .compact ? member.organization.nickName :
                                                             member.organization.fullName))
                .navigationBarTitleDisplayMode(.inline)
        }
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ReadmeButton()
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { isSearchPresented = true } label: {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
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
