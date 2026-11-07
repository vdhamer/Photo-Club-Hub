//
//  FilteredMemberPortfoliosView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 29/12/2021.
//

import CoreData // for NSManagedObjectContext, FetchRequest
import SwiftUI
import Photo_Club_Hub_Data // for types like MemberPortfolio

/// Renders `MemberPortfolioRow` views grouped by Club, driven by a Core Data sectioned fetch request.
/// Sections are labeled by Club name+town and include member-count footers.
/// Accepts an `NSPredicate` and a search-text binding for two-level runtime filtering.
struct FilteredMemberPortfoliosView: View {

    /// Would return nothing — safe initial state before the real predicate is injected via `init`.
    private static let predicateNone = NSPredicate(format: "FALSEPREDICATE")

    @Environment(\.managedObjectContext) private var viewContext

    /// Sectioned fetch results keyed per Club by `fullNameTown`.
    /// Replaced within `init` with actuall request predicate and sort order.
    @SectionedFetchRequest<String, MemberPortfolio>(
        sectionIdentifier: \.organizationSectionID, // not \.organization_!... : that traps on a deleted row (#802)
        sortDescriptors: [],
        predicate: predicateNone
    ) private var sectionedMemberPortfolios: SectionedFetchResults<String, MemberPortfolio>

    /// Unfiltered query just to answer the question: does the data store hold *any* member at all?
    /// That separates "nothing has been loaded" from "your filters hide everything", which the sectioned
    /// request above cannot distinguish because its own predicate is one of the suspects (#821).
    /// Only `isEmpty` is ever read — never a relationship — so it stays clear of the deleted-row
    /// accessors that `isUsable` guards against (#802).
    @FetchRequest(fetchRequest: {
        let request = MemberPortfolio.fetchRequest()
        request.sortDescriptors = [] // required: @FetchRequest traps on a request with nil sortDescriptors
        request.fetchLimit = 1       // one row is enough to answer "any?"
        return request
    }()) private var anyMemberProbe: FetchedResults<MemberPortfolio>

    /// The language the section headers show the town in: the app's own resolved interface language
    /// (see `Language.interfaceLanguageRequest`). Empty only if `Language.initConstants` has not run.
    @FetchRequest(fetchRequest: Language.interfaceLanguageRequest)
    private var uiLanguages: FetchedResults<Language> // fetchRequests returns array, although this hold only 1

    /// Never directly read: it exists only so that a town geocoded after this view appeared redraws the headers.
    /// A new or changed `LocalizedAddress` does not change any `MemberPortfolio`, so the sectioned request above
    /// does not report it (#862).
    @FetchRequest(sortDescriptors: [])
    private var localizedAddresses: FetchedResults<LocalizedAddress>

    /// Bound to the parent's search field; changes here trigger re-filtering without a new fetch.
    private let searchText: Binding<String>
    /// Parent-owned selection: a row sets it to trigger navigation via the parent's `navigationDestination(item:)`,
    /// which must be registered outside this lazy `List` content.
    private let selectedPortfolio: Binding<MemberPortfolio?>

    /// Replaces `predicateNone` with `memberPredicate` and applies the standard sort order.
    init(memberPredicate: NSPredicate,
         searchText: Binding<String>,
         selectedPortfolio: Binding<MemberPortfolio?>) {
    // https://developer.apple.com/documentation/SwiftUI/SectionedFetchRequest
    // When you need to dynamically change the section identifier, predicate, or sort descriptors,
    // access the request's SectionedFetchRequest.Configuration structure, either directly or with a binding.
        let sortDescriptors = [ // XCode had problems parsing this array
            SortDescriptor(\MemberPortfolio.organization_!.pinned, order: .reverse),
            SortDescriptor(\MemberPortfolio.organization_!.fullName_, order: .forward),
            SortDescriptor(\MemberPortfolio.organization_!.town_, order: .forward),
            SortDescriptor(\MemberPortfolio.photographer_!.givenName_, order: .forward),
            SortDescriptor(\MemberPortfolio.photographer_!.familyName_, order: .forward)
        ]
        _sectionedMemberPortfolios = SectionedFetchRequest(
            sectionIdentifier: \.organizationSectionID, // see the property wrapper above for why not \.organization_!
            sortDescriptors: sortDescriptors,
            predicate: memberPredicate,
            animation: .default)
        self.searchText = searchText
        self.selectedPortfolio = selectedPortfolio
    }

    // MARK: - body

    var body: some View {
        let sectionedPortfoliosResults = sectionedMemberPortfolios // copy results to avoid recomputation
        let titles = sectionTitles(for: sectionedPortfoliosResults) // read Core Data here, on the main thread
        // Like a `guard`: deal with the reasons the list could be empty, then get on with the happy flow
        // below. Every reason but `.listHasRows` implies no section survives the filter, so the two never
        // both show.
        EmptyListHint(reason: emptyListReason(for: sectionedPortfoliosResults),
                      tint: .clubsColor,
                      wording: { hintText(for: $0) }) // not `hintText`: previews fail to compile it
            .listRowSeparator(.hidden) // also covers the spinner branch, which is not a CalloutBox
        ForEach(sectionedPortfoliosResults) { section in
            let filteredPortfolios = filterMemberPortfolios(unFilteredPortfolios: section)
            if !filteredPortfolios.isEmpty { // suppress section if Search filter leaves it without any members
                Section {
                    ForEach(filteredPortfolios, id: \.id) { filteredMember in
                        MemberPortfolioRow(member: filteredMember,
                                           selectedPortfolio: selectedPortfolio)
                            .listRowSeparator(.visible)
                    }
                    .tint(.clubsColor)
                } header: {
                    MemberListSectionHeader(name: titles[section.id]?.name ?? section.id, // Strings, not the club
                                            town: titles[section.id]?.town) // see sectionTitles(for:) and #802
                } footer: {
                    MemberListSectionFooter(filtCount: filteredPortfolios.count,
                                            unfiltCount: section.endIndex,
                                            organization: section.first?.organization
                    )
                }
                .listRowSeparator(.hidden) // prevents a separator below the footer.
                .id(section.id)
            }
        }
    }

    // MARK: - section titles

    /// The title users see above each section, keyed by section id (`fullNameTown`): the club name, and the town
    /// in the interface language unless the name already contains it (`fullNameLocalizedTown`, Data#88).
    ///
    /// The title cannot be the section id itself, which must stay the same in every language. Nor can the header
    /// look up the club itself, because reaching back to the organization traps on a row deleted mid-scroll (#802).
    /// So the titles are computed here, in `body` on the main thread, and the header and the `ForEach` content,
    /// which SwiftUI may evaluate on a background thread, read only this dictionary.
    ///
    /// Name and town are kept apart because the header sets the town a size smaller. Splitting the composed
    /// string later would fail on parentheses inside a name ("... (AFO)") or a town ("Beuningen (Gld)").
    /// A section without a usable row, or a missing `Language` row, gets no entry: its header falls back to
    /// the section id.
    private func sectionTitles(for sections: SectionedFetchResults<String, MemberPortfolio>)
                              -> [String: (name: String, town: String?)] {
        guard let uiLanguage = uiLanguages.first else { return [:] } // Language table not seeded yet
        var titles: [String: (name: String, town: String?)] = [:]
        for section in sections {
            guard let organization = section.first(where: { $0.isUsable })?.organization_ else { continue }
            titles[section.id] = Self.sectionTitle(for: organization, language: uiLanguage)
        }
        return titles
    }

    /// One section's title: the club name, and its town in `language` unless the name already contains it.
    ///
    /// `fullNameLocalizedTown` returns either the name alone or "name (town)", so the town is what follows the name
    /// and " (", minus the closing ")". Cutting by the name's length rather than searching for " (" keeps any
    /// parentheses inside the name or the town where they belong.
    static func sectionTitle(for organization: Organization, language: Language) -> (name: String, town: String?) {
        let name = organization.fullName
        let title = organization.fullNameLocalizedTown(for: language) // either `name` or "name (town)"
        let town: String? = title == name ? nil : String(title.dropFirst(name.count + 2).dropLast())
        return (name: name, town: town)
    }

    // MARK: - explaining an empty list

    /// Picks the single reason the list is empty. The priority order itself lives in
    /// `EmptyListReason.resolve`, shared with Maps and People; only the inputs below are specific to
    /// this screen (#821).
    private func emptyListReason(for sections: SectionedFetchResults<String, MemberPortfolio>)
                                -> EmptyListReason {
        EmptyListReason.resolve(hasVisibleRows: !allSectionsFilterToZero(sections),
                                allCategoriesOff: sections.nsPredicate == Self.predicateNone,
                                storeIsEmpty: anyMemberProbe.isEmpty,
                                searchIsEmpty: searchText.wrappedValue.isEmpty)
    }

    /// The wording for each reason that has any. `nil` covers the two cases where the screen should stay
    /// silent: rows are on display, or a pull-to-refresh is in progress and its spinner has already said it.
    private func hintText(for reason: EmptyListReason) -> Text? {
        switch reason {

        case .listHasRows, .refreshing, .buildingDatabase:
            return nil

        case .noCategoriesEnabled:
            return Text("""
                        Warning: all member categories on the Settings page are disabled. \
                        Please enable one or more options in Settings.
                        """,
                        tableName: "PhotoClubHub.SwiftUI",
                        comment: "Hint to the user if all of the Settings toggles are disabled.")

        case .databaseEmpty:
            return Text("""
                        To see names here, pull the list down to load the data.
                        """,
                        tableName: "PhotoClubHub.SwiftUI",
                        comment: """
                                 Hint to the user when the database holds no members at all, \
                                 e.g. after the Load data manually setting emptied it.
                                 """)

        case .searchFilterTooStrict:
            return Text("""
                        To see names here, please adapt the Search filter \
                        or enable additional categories on the Settings page.
                        """,
                        tableName: "PhotoClubHub.SwiftUI",
                        comment: "Hint to the user if zero Members remain visible with Search filter in use.")

        case .categoriesTooStrict:
            return Text("""
                        To see names here, please enable additional categories on the Settings page.
                        """,
                        tableName: "PhotoClubHub.SwiftUI",
                        comment: "Hint to the user if the database returns zero Members with empty Search filter.")
        }
    }

    /// Returns the first `Photographer` that appears multiple times in `memberPortfolios` or `nil` if all are distinct.
    /// The `findFirstNonDistinct()`function is not currently used. Not sure why it was created.
    private func findFirstNonDistinct(memberPortfolios: [MemberPortfolio]) -> Photographer? {
        let members = memberPortfolios.sorted()
        var previousMemberPortfolio: MemberPortfolio?

        for member in members {
            if let previousMember = previousMemberPortfolio {
                if previousMember.photographer == member.photographer {
                    return member.photographer
                }
            }
            previousMemberPortfolio = member
        }
        return nil
    }

    /// Returns `true` if nothing remains to display: every fetched section (possibly none at all)
    /// filters down to zero members. This, rather than `sections.isEmpty`, is what "the list looks empty"
    /// means — sections whose rows are all filtered out are suppressed in `body`, and sections whose rows
    /// were all just deleted lose them to the `isUsable` test below, so either can leave the user staring
    /// at a blank list while `isEmpty` insists there is something there.
    private func allSectionsFilterToZero(_ sections: SectionedFetchResults<String, MemberPortfolio>) -> Bool {
        sections.allSatisfy { filterMemberPortfolios(unFilteredPortfolios: $0).isEmpty }
    }

    /// Filters one section's portfolios by `searchText` (name or expertise), converting the opaque
    /// `SectionedFetchResults.Element` to a plain `[MemberPortfolio]` that SwiftUI `ForEach` can consume.
    private func filterMemberPortfolios(unFilteredPortfolios: SectionedFetchResults<String,
                                        MemberPortfolio>.Element)
                                    -> [MemberPortfolio] {
        let filteredPortfolios: [MemberPortfolio]

        // isUsable keeps rows that pull-to-refresh has just deleted out of the view tree: their
        // relationships are already nullified, so both rendering them and the search test below
        // (which dereferences photographer) would trip the accessors (issue #802).
        if searchText.wrappedValue.isEmpty {
            filteredPortfolios = unFilteredPortfolios.filter { memberPortfolio in
                memberPortfolio.isUsable
            }
        } else {
            filteredPortfolios = unFilteredPortfolios.filter { memberPortfolio in
                memberPortfolio.isUsable && (
                    memberPortfolio.photographer.fullNameFirstLast
                        .localizedCaseInsensitiveContains(searchText.wrappedValue) ||
                    comparePhotographerExpertisesToSearchText(
                        photographerExpertises: memberPortfolio.photographer.photographerExpertises
                    )
                )
            }
        }

        return filteredPortfolios
    }

    /// Returns `true` if any of the photographer's expertise names contain `searchText` (case-insensitive).
    private func comparePhotographerExpertisesToSearchText(photographerExpertises: Set<PhotographerExpertise>) -> Bool {
        for photographerExpertise in photographerExpertises where
            photographerExpertise.expertise // check every Expertise
                                 .selectedLocalizedExpertise().name // gets its name in selected language
                                 .localizedCaseInsensitiveContains(searchText.wrappedValue) {
            return true // doing an || here across all elements of the Set
        }
        return false
    }

}

// MARK: - Previews

// Believe it or not, the following preview works.

// Note that the preview filters on `searchText`, but `searchText` is not shown in this child View.
// @Previewable @State (Xcode 16+) wires up state directly in the #Preview closure without a wrapper view.
#Preview {
    @Previewable @State var searchText: String = "8"
    // Tapping a row does not navigate in this preview: the matching `navigationDestination(item:)`
    // is registered by the parent view (MemberPortfolioView), which is not part of this preview.
    @Previewable @State var selectedPortfolio: MemberPortfolio?
    let memberPredicate = NSPredicate(format: "photographer_.givenName_ = %@", argumentArray: ["Jan"])
    NavigationStack {
        if #available(iOS 26, *) {
            List { // lists are "Lazy" automatically
                FilteredMemberPortfoliosView(memberPredicate: memberPredicate,
                                             searchText: $searchText,
                                             selectedPortfolio: $selectedPortfolio)
            }
            .navigationTitle(Text(verbatim: "FilteredMemberPortfoliosView")) // no localization (only used for preview)
            .searchable(text: $searchText, placement: .toolbar, prompt: Text(verbatim: "Search names (preview)"))
            .searchToolbarBehavior(.minimize) // iOS 26+
        } else {
            List { // lists are "Lazy" automatically
                FilteredMemberPortfoliosView(memberPredicate: memberPredicate,
                                             searchText: $searchText,
                                             selectedPortfolio: $selectedPortfolio)
            }
            .navigationTitle(Text(verbatim: "FilteredMemberPortfoliosView")) // no localization (only used for preview)
            .searchable(text: $searchText, placement: .toolbar, prompt: Text(verbatim: "Search names (preview)"))
        }
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
