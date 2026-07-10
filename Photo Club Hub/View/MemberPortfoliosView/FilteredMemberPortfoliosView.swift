//
//  FilteredMemberPortfoliosView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 29/12/2021.
//

import CoreData // for NSManagedObjectContext, FetchRequest
import SwiftUI

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
        sectionIdentifier: \.organization_!.fullNameTown,
        sortDescriptors: [],
        predicate: predicateNone
    ) private var sectionedMemberPortfolios: SectionedFetchResults<String, MemberPortfolio>

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
            sectionIdentifier: \.organization_!.fullNameTown,
            sortDescriptors: sortDescriptors,
            predicate: memberPredicate,
            animation: .default)
        self.searchText = searchText
        self.selectedPortfolio = selectedPortfolio
    }

    // MARK: - body

    var body: some View {
        let sectionedPortfoliosResults = sectionedMemberPortfolios // copy results to avoid recomputation
        ForEach(sectionedPortfoliosResults) { section in
            let filteredPortfolios = filterMemberPortfolios(unFilteredPortfolios: section)
            Section {
                ForEach(filteredPortfolios, id: \.id) { filteredMember in
                    MemberPortfolioRow(member: filteredMember,
                                       selectedPortfolio: selectedPortfolio)
                        .listRowSeparator(.visible)
                }
                .tint(.memberPortfolioColor)
            } header: {
                MemberListSectionHeader(title: section.id) // String used to group the elements into Sections
            } footer: {
                MemberListSectionFooter(filtCount: filteredPortfolios.count,
                                        unfiltCount: section.endIndex,
                                        organization: section.first?.organization
                )
            }
            .listRowSeparator(.hidden) // prevents a separator below the footer.
        }
        if sectionedPortfoliosResults.nsPredicate == Self.predicateNone {
            Text("""
                 Warning: all member categories on the Preferences page are disabled. \
                 Please enable one or more options in Preferences.
                 """,
                 tableName: "PhotoClubHub.SwiftUI",
                 comment: "Hint to the user if all of the Preference toggles are disabled.")
        } else if searchText.wrappedValue != "" && sectionedPortfoliosResults.isEmpty {
            Text("""
                 To see names here, please adapt the Search filter \
                 or enable additional categories on the Preferences page.
                 """,
                 tableName: "PhotoClubHub.SwiftUI",
                 comment: "Hint to the user if the database returns zero Members with Search filter in use.")
        } else if searchText.wrappedValue == "" && sectionedPortfoliosResults.isEmpty {
            Text("""
                 To see names here, please enable additional categories on the Preferences page.
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

    /// Filters one section's portfolios by `searchText` (name or expertise), converting the opaque
    /// `SectionedFetchResults.Element` to a plain `[MemberPortfolio]` that SwiftUI `ForEach` can consume.
    private func filterMemberPortfolios(unFilteredPortfolios: SectionedFetchResults<String,
                                        MemberPortfolio>.Element)
                                    -> [MemberPortfolio] {
        let filteredPortfolios: [MemberPortfolio]

        if searchText.wrappedValue.isEmpty {
            filteredPortfolios = unFilteredPortfolios.filter { _ in true } // to convert types
        } else {
            filteredPortfolios = unFilteredPortfolios.filter { memberPortfolio in
                memberPortfolio.photographer.fullNameFirstLast
                    .localizedCaseInsensitiveContains(searchText.wrappedValue) ||
                comparePhotographerExpertisesToSearchText(
                    photographerExpertises: memberPortfolio.photographer.photographerExpertises
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
