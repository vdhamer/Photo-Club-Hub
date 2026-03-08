//
//  FilteredMemberPortfoliosView1718.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 29/12/2021.
//

import SwiftUI
import WebKit // for wkWebView

@available(iOS, obsoleted: 19.0, message: "Please use 'FilteredOrganizationView_Previews2626' for versions > iOS 18.x")
struct FilteredMemberPortfoliosView1718: View {
    private static let predicateNone = NSPredicate(format: "FALSEPREDICATE")

    @Environment(\.managedObjectContext) private var viewContext

    @SectionedFetchRequest<String, MemberPortfolio>(
        sectionIdentifier: \.organization_!.fullNameTown,
        sortDescriptors: [],
        predicate: predicateNone
    ) private var sectionedPortfolios: SectionedFetchResults<String, MemberPortfolio>

    private let searchText: Binding<String>
    private let wkWebView = WKWebView()

    // regenerate Section using current FetchRequest with current filters and sorting
    init(memberPredicate: NSPredicate, searchText: Binding<String>) {
    // https://developer.apple.com/documentation/SwiftUI/SectionedFetchRequest
    // When you need to dynamically change the section identifier, predicate, or sort descriptors,
    // access the request’s SectionedFetchRequest.Configuration structure, either directly or with a binding.

        let sortDescriptors = [ // XCode had problems parsing this array
            SortDescriptor(\MemberPortfolio.organization_!.pinned, order: .reverse),
            SortDescriptor(\MemberPortfolio.organization_!.fullName_, order: .forward),
            SortDescriptor(\MemberPortfolio.organization_!.town_, order: .forward),
            SortDescriptor(\MemberPortfolio.photographer_!.givenName_, order: .forward),
            SortDescriptor(\MemberPortfolio.photographer_!.familyName_, order: .forward)
        ]
        _sectionedPortfolios = SectionedFetchRequest(
            sectionIdentifier: \.organization_!.fullNameTown,
            sortDescriptors: sortDescriptors,
            predicate: memberPredicate,
            animation: .default)
        self.searchText = searchText
    }

    var body: some View {
        let sectionedPortfoliosResults = sectionedPortfolios // copy results to avoid recomputation
        ForEach(sectionedPortfoliosResults) {section in
            Section {
                ForEach(filterPortfolios(unFilteredPortfolios: section), id: \.id) { filteredMember in
                    MemberPortfolioRow(member: filteredMember, wkWebView: wkWebView)
                        .listRowSeparator(.visible)
                }
                .accentColor(.memberPortfolioColor)
            } header: {
                Header(title: section.id) // String used to group the elements into Sections
            } footer: {
                Footer(filtCount: filterPortfolios(unFilteredPortfolios: section).count,
                       unfiltCount: section.endIndex,
                       listName: section.id,
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

    private struct Header: View {
        @Environment(\.colorScheme) private var colorScheme // to detect dark mode
        var title: String

        var body: some View {
            HStack {
                Spacer()
                ZStack {
                    Capsule(style: .continuous)
                        .fill(Gradient(colors: [.gray.opacity(0.5),
                                                .gray.opacity(0.1),
                                                .gray.opacity(0.2),
                                                .gray.opacity(0.5)]))
                        .frame(maxWidth: 400, alignment: .center)
                    Text(title) // String used to group the elements into Sections
                        .font(.title2)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                 }
                Spacer()
            }
        }
    }

    private struct Footer: View {
        var filtCount: Int // // number of items in filtered list
        var unfiltCount: Int // number of items in unfiltered list
        var listName: String
        var organization: Organization? // optional because we copy this from first member in the photoClub collection
        let member = String(localized: "member_",
                            table: "PhotoClubHub.SwiftUI",
                            comment: "Statistics at end of section of FilteredMemberPortfoliosView")
        let members = String(localized: "members",
                             table: "PhotoClubHub.SwiftUI",
                             comment: "Statistics at end of section of FilteredMemberPortfoliosView")
        let shown = String(localized: "shown",
                           table: "PhotoClubHub.SwiftUI",
                           comment: "X member(s) shown (due to various forms of filtering)")
        let of1 = String(localized: "of1",
                         table: "PhotoClubHub.SwiftUI",
                         comment: "X of Y portfolio(s) shown (due to various forms of filtering)")

        var body: some View {
            HStack {
                Spacer()
                VStack {
                    if filtCount < unfiltCount {
                        Text(verbatim: // verbatim keeps these pretty empty strings out of the localized Strings
                             "\(filtCount) \(filtCount==1 ? member : members) (\(of1) \(unfiltCount)) \(shown).")
                    } else {
                        Text(verbatim:
                             "\(unfiltCount) \(unfiltCount==1 ? member : members) \(shown).")
                    }
                    if organization != nil,
                       organization!.level2URL != nil,
                       organization!.level2URL!.host != nil,
                       organization!.level2URL!.scheme != nil {
                            Text(String(localized: """
                                                   Data source: \(organization!.level2URL!.scheme!)://\
                                                   \(organization!.level2URL!.host!)\
                                                   \(organization!.level2URL!.path)/
                                                   """,
                                table: "PhotoClubHub.SwiftUI",
                                comment: "Section footer text Portfolios screen"))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                    .font(.subheadline)
                    .dynamicTypeSize( // constrain impact of large dynamic type
                        ...DynamicTypeSize.large) // this is just supposed to be a footer, so don't want it too big
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }

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

    @MainActor
    private func deleteMembers(section: [MemberPortfolio], indexSet: IndexSet) { // only temporarily deletes member
        // This function is no longer called (replaced by pull-down-to-reload data) but is kept for possible future use.

        for index in indexSet {
            let memberPortfolio = section[index] // could use map()
            viewContext.delete(memberPortfolio)
        }

        do {
            if viewContext.hasChanges {
                try viewContext.save() // persist deleted members (on main thread)
                print("Deleted member")
            }
        } catch {
            let nsError = error as NSError
            ifDebugFatalError("Unresolved error deleting members \(nsError), \(nsError.userInfo)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, the failed deletion is only logged. App doesn't stop.
        }
    }

    // dynamically filter a sectionedFetchResult based on the bound searchText
    // The input type and output type differ: .filter returns a different data type (why?)
    // But the output type is simpler, and also works in a SwiftUI ForEach.
    private func filterPortfolios(unFilteredPortfolios: SectionedFetchResults<String, MemberPortfolio>.Element)
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

    private func comparePhotographerExpertisesToSearchText(photographerExpertises: Set<PhotographerExpertise>) -> Bool {
        for photographerExpertise in photographerExpertises where
            photographerExpertise.expertise // check every Expertise
                                 .selectedLocalizedExpertise.name // gets its name in selected language
                                 .localizedCaseInsensitiveContains(searchText.wrappedValue) {
            return true // doing an || here across all elements of the Set
        }
        return false
    }

}

@available(iOS, obsoleted: 19.0, message: "Please use 'FilteredOrganizationView_Previews2626' for versions > iOS 18.x")
struct FilteredMemberPortfolios1718_Previews: PreviewProvider {
    static let memberPredicate = NSPredicate(format: "photographer_.givenName_ = %@", argumentArray: ["Jan"])
    @State static var searchText: String = ""

    static var previews: some View {
        List { // lists are "Lazy" automatically
            FilteredMemberPortfoliosView1718(memberPredicate: memberPredicate, searchText: $searchText)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
        .navigationBarTitle(Text(String("FilteredMemberPortfoliosView"))) // prevent localization
        .searchable(text: $searchText, placement: .toolbar, prompt: Text(verbatim: "Search names (preview)"))
    }
}
