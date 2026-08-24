//
//  FilteredPhotographerView2627.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import CoreData // for NSManagedObjectContext, FetchRequest
import SwiftUI // for View
import WebKit // for WKWebView
import Photo_Club_Hub_Data // for types like Photographer

// Implements list of photographer cards including
//      * defining fetchRequest to get list of photographers sorted on last name
//      * filtering the photographer list based on search bar string
//      * per photographer card, it displays
//          - an icon (with a special icon if the photographer is deceased)
//          - photographer's name (last name first)
//          - optionally a link icon that leads to the phototographer's own website
//          - some textual information
//          - a horizontally scrolling list of thumbnails representing portfolios

@available(iOS 26.0, *)
struct FilteredPhotographerView2627: View {

    @Environment(\.managedObjectContext) private var viewContext // may not be correct
    @FetchRequest var fetchedPhotographers: FetchedResults<Photographer>

    /// Unfiltered query answers just one question: does the store hold *at least one* Photographer?
    /// That separates "nothing has been loaded" from "your Search text hides everything" (#821).
    /// Only `isEmpty` is ever read — never a relationship — so it stays clear of the deleted-row
    /// accessors that `isUsable` guards against (#802).
    @FetchRequest(fetchRequest: {
        let request = Photographer.fetchRequest()
        request.sortDescriptors = [] // required: @FetchRequest traps on a request with nil sortDescriptors
        request.fetchLimit = 1       // one row is enough to answer "any?"
        return request
    }()) private var anyPhotographerProbe: FetchedResults<Photographer>

    private let isDeletePhotographersPermitted = true // enable/disable .onDelete() functionality for this screen
    let searchText: Binding<String>
    let wkWebView: WKWebView
    /// Set by tapping a caption or chevron; the screen-level view owns the navigationDestination(item:).
    /// Navigation destinations may not be declared inside lazy containers (List rows, LazyVStack).
    let selectedPortfolio: Binding<MemberPortfolio?>

    // regenerate Section using current FetchRequest with current filters and sorting
    init(predicate: NSPredicate, searchText: Binding<String>, wkWebView: WKWebView,
         selectedPortfolio: Binding<MemberPortfolio?>) {
        _fetchedPhotographers = FetchRequest<Photographer>(sortDescriptors: [ // replaces previous fetchedPhotographers
                                                        SortDescriptor(\.familyName_, order: .forward),
                                                        SortDescriptor(\.givenName_, order: .forward)],
                                                   predicate: predicate,
                                                   animation: .default)
        self.searchText = searchText
        self.wkWebView = wkWebView
        self.selectedPortfolio = selectedPortfolio
    }

    var body: some View {
        ItemFilterStatsView(filteredCount: filteredPhotographers.count,
                            unfilteredCount: fetchedPhotographers.count,
                            unit: .photographer)
        // Like a `guard`: deal with the reasons the screen could be empty, then get on with the happy flow
        // below. Every reason but `.listHasRows` implies the ForEach is empty, so the two never both show.
        EmptyListHint(reason: emptyListReason(),
                      tint: .peopleColor,
                      wording: hintText)
        ForEach(filteredPhotographers, id: \.id) { photographer in // each photographer's "card"
            VStack(alignment: .leading) { // there are horizontal layers within each photographer's "card"
                HStack(alignment: .top) { // first row within each photographer's "card" with textual info

                    PhotographerIconView2627(isDeceased: photographer.isDeceased)
                        .foregroundStyle(.peopleColor, .gray, .red) // red tertiary color should not show up
                        .font(.title3)
                        .frame(width: 35)
                        .padding(.top, 3)

                    PhotographersTextInfo(photographer: photographer, wkWebView: wkWebView)

                    Spacer() // push PhotographersTextInfo to the left

                    if let url: URL = photographer.photographerWebsite {
                        Link(destination: url, label: {
                            Image(systemName: "link")
                                .foregroundColor(.linkColor)
                        })
                        .buttonStyle(.plain) // to avoid entire List element being clickable
                    }

                } // HStack

                PhotographersThumbnails(photographer: photographer, selectedPortfolio: selectedPortfolio)

            } // VStack
            .accentColor(.peopleColor)
            .foregroundColor(chooseColor(accentColor: .accentColor,
                                         isDeceased: photographer.isDeceased))
        } // ForEach filteredPhotographer
        .onDelete { indexSet in
            deletePhotographers(indexSet: indexSet) // can be disabled using isDeletedPhotographerEnabled flag
        }
    } // body

    // MARK: - explaining an empty on-screen list to the user

    /// Picks the single reason the screen is empty. The priority order itself lives in
    /// `EmptyListReason.resolve`, shared with Clubs and Maps; only the inputs below are specific to
    /// this screen.
    ///
    /// `allCategoriesOff` is always `false` here: `photographerPredicate` is hardcoded `TRUEPREDICATE`
    /// in `SettingsViewModel`, with all filtering done in this view, so People has no category toggles
    /// to switch off. People had no hint at all before this, so unlike Maps it had nothing to flash and
    /// no wrong wording — it simply left "0 photographers" above the gray captions (#821).
    private func emptyListReason() -> EmptyListReason {
        EmptyListReason.resolve(hasVisibleRows: !filteredPhotographers.isEmpty,
                                allCategoriesOff: false,
                                storeIsEmpty: anyPhotographerProbe.isEmpty,
                                searchIsEmpty: searchText.wrappedValue.isEmpty)
    }

    /// The wording for each reason that has any. `nil` covers the two cases where the screen should stay
    /// silent: photographers are on display, or a pull-to-refresh is in progress and its spinner said it.
    private func hintText(for reason: EmptyListReason) -> Text? {
        switch reason {

        case .listHasRows, .refreshing, .buildingDatabase:
            return nil

        case .noCategoriesEnabled: // unreachable: People has no category toggles to switch off
            return nil

        // `.categoriesTooStrict` reaches People in one state only: photographers are stored but none are
        // usable, because their rows are mid-deletion. There is no category to widen, and a refresh is
        // what fixes it — which is exactly what the wording below already advises.
        case .databaseEmpty, .categoriesTooStrict:
            return Text("""
                        To see photographers here, pull the list down to load the data.
                        """,
                        tableName: "PhotoClubHub.SwiftUI",
                        comment: """
                                 Hint to the user when the database holds no photographers at all, \
                                 e.g. after the Load data manually setting emptied it.
                                 """)

        case .searchFilterTooStrict: // no "or enable more categories": People has no category toggles to enable
            return Text("""
                        To see photographers here, please change the Search (filter) text.
                        """,
                        tableName: "PhotoClubHub.SwiftUI",
                        comment: "Hint to the user if zero Photographers remain visible with Search filter in use.")
        }
    }

    // isUsable keeps rows that pull-to-refresh has just deleted out of the view tree: their
    // relationships are already nullified, so rendering them trips the accessors (issue #802).
    private var filteredPhotographers: [Photographer] {
        if searchText.wrappedValue.isEmpty {
            return fetchedPhotographers.filter { photographer in
                photographer.isUsable
            }
        } else {
            return fetchedPhotographers.filter { photographer in
                photographer.isUsable &&
                photographer.fullNameFirstLast.localizedCaseInsensitiveContains(searchText.wrappedValue) }
        }
    }

    private func chooseColor(accentColor: Color, isDeceased: Bool) -> Color {
        isDeceased ? .deceasedColor : .peopleColor
    }

    @MainActor
    private func deletePhotographers(indexSet: IndexSet) {
        guard isDeletePhotographersPermitted else { return } // exit if feature is disabled

        let fullName: String = indexSet.map { filteredPhotographers[$0] }.first?.fullNameFirstLast ?? "noName"
        indexSet.map { filteredPhotographers[$0] }.forEach( viewContext.delete )

        do {
            if viewContext.hasChanges {
                try viewContext.save() // persist deletion of photographer (on main thread)
                print("Deleted photographer \(fullName) and any associated memberships")
            }
        } catch {
            let nsError = error as NSError
            ifDebugFatalError("Unresolved error deleting photographer \(fullName): \(nsError), \(nsError.userInfo)",
                              file: #fileID, line: #line) // expect deprecation of #fileID in Swift 6.0
            // in release mode, the failed deletion is only logged. App doesn't stop.
        }
    }

}

@available(iOS 26.0, *)
private struct PhotographerIconView2627: View {
    let isDeceased: Bool

    var body: some View {
        if isDeceased {
            Image("deceased.photographer")
        } else {
            Image(systemName: "person.text.rectangle")
        }
    }
}

// MARK: - Previews

// Believe it or not, the following Previews actually works.
// The first one was generated in a lengthy session by Claude Code (Opus 4.7).
// The List { } thing was likely needed to fix a bug somewhere.
@available(iOS 26.0, *)
#Preview("FilteredPhotographerView2627") {
    @Previewable @State var selectedPortfolio: MemberPortfolio?
    NavigationStack {
        List {
            FilteredPhotographerView2627(predicate: NSPredicate(value: true),
                                         searchText: .constant(""),
                                         wkWebView: WKWebView(),
                                         selectedPortfolio: $selectedPortfolio)
        }
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

@available(iOS 26.0, *)
#Preview("PhotographerIconView2627") {
    NavigationStack {
        VStack(spacing: 20) {
            HStack {
                PhotographerIconView2627(isDeceased: false)
                Text(verbatim: "isDeceased: false")
            }
            HStack {
                PhotographerIconView2627(isDeceased: true)
                Text(verbatim: "isDeceased: true")
            }
        }
        .font(.title3)
        .foregroundStyle(.peopleColor, .gray, .red)
        .padding()
    }    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
