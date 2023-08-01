//
//  FilteredMemberPortfoliosView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 29/12/2021.
//

import SwiftUI

struct FilteredMemberPortfoliosView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @SectionedFetchRequest<String, MemberPortfolio>(
        sectionIdentifier: \.photoClub_!.fullNameTown,
        sortDescriptors: [],
        predicate: NSPredicate.none
    ) private var sectionedPortfolios: SectionedFetchResults<String, MemberPortfolio>

    let searchText: Binding<String>

    // regenerate Section using current FetchRequest with current filters and sorting
    init(predicate: NSPredicate, searchText: Binding<String>) {
    // https://developer.apple.com/documentation/SwiftUI/SectionedFetchRequest
    // When you need to dynamically change the section identifier, predicate, or sort descriptors,
    // access the request’s SectionedFetchRequest.Configuration structure, either directly or with a binding.

        let sortDescriptors = [ // XCode had problems parsing this array
            SortDescriptor(\MemberPortfolio.photoClub_!.name_, order: .forward),
            SortDescriptor(\MemberPortfolio.photoClub_!.town_, order: .forward),
            SortDescriptor(\MemberPortfolio.photographer_!.givenName_, order: .forward),
            SortDescriptor(\MemberPortfolio.photographer_!.familyName_, order: .forward)
        ]
        _sectionedPortfolios = SectionedFetchRequest(
            sectionIdentifier: \.photoClub_!.fullNameTown,
            sortDescriptors: sortDescriptors,
            predicate: predicate,
            animation: .default)
        self.searchText = searchText
    }

    var body: some View {
        let sectionedPortfoliosResults = sectionedPortfolios // copy results to avoid recomputation
        ForEach(sectionedPortfoliosResults) {section in
//            VStack {
                Section {
                    ForEach(filterPortfolios(unFilteredPortfolios: section), id: \.id) { filteredMember in
                        MemberPortfolioRow(member: filteredMember, showPhotoClub: true)
                    }
                    .onDelete(perform: { indexSet in
                        deleteMembers(section: Array(section), indexSet: indexSet)
                    })
                    .accentColor(.memberPortfolioColor)
                } header: {
                    Header(title: section.id) // String used to group the elements into Sections
                } footer: {
                    Footer(filtCount: filterPortfolios(unFilteredPortfolios: section).count,
                           unfiltCount: section.endIndex,
                           listName: section.id,
                           photoClub: section.first?.photoClub
                    )
                }// }
                .listRowSeparator(.hidden)
//                .padding() // disabled because it doesn't work in combination with sectioning
//                .background(Color(.secondarySystemBackground)) // compatible with light and dark mode
//                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 25.0, height: 25.0)))
        }
        if sectionedPortfoliosResults.nsPredicate == NSPredicate.none {
            Text("""
                 Warning: all member categories on the Preferences page are disabled. \
                 Please enable one or more options in Preferences.
                 """, comment: "Hint to the user if all of the Preference toggles are disabled.")
        } else if searchText.wrappedValue != "" && sectionedPortfoliosResults.isEmpty {
            Text("""
                 To see names here, please adapt the Search filter \
                 or enable additional categories on the Preferences page.
                 """, comment: "Hint to the user if the database returns zero Members with Search filter in use.")
        } else if searchText.wrappedValue == "" && sectionedPortfoliosResults.isEmpty {
            Text("""
                 To see names here, please enable additional categories on the Preferences page.
                 """, comment: "Hint to the user if the database returns zero Members with empty Search filter.")
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
        var photoClub: PhotoClub? // optional because we copy this from first member in the photoClub collection
        let member = String(localized: "member",
                               comment: "Statistics at end of section of FilteredMemberPortfoliosView")
        let members = String(localized: "members",
                                comment: "Statistics at end of section of FilteredMemberPortfoliosView")
        let shown = String(localized: "shown",
                           comment: "X member(s) shown (due to various forms of filtering)")
        let of1 = String(localized: "of1",
                           comment: "X of Y member(s) shown (due to various forms of filtering)")

        var body: some View {
            HStack {
                Spacer()
                VStack {
                    if filtCount < unfiltCount {
                        Text(verbatim: // verbatim keeps these pretty empty strings out of the localized Strings
                             "\(filtCount) (\(of1) \(unfiltCount)) \(filtCount==1 ? member : members) \(shown).")
                    } else {
                        Text(verbatim:
                             "\(unfiltCount) \(unfiltCount==1 ? member : members) \(shown).")
                    }
                    if let photoClub, photoClub.hasHardCodedMemberData {
                        Text("Data source: in-app member data.", comment: "Section footer text Portfolios screen")
                    }
                    if photoClub != nil,
                       photoClub!.memberListURL != nil,
                       photoClub!.memberListURL!.host != nil,
                       photoClub!.memberListURL!.scheme != nil {
                            Text(String(localized:
                                """
                                Data source: \(photoClub!.memberListURL!.scheme!)://\
                                \(photoClub!.memberListURL!.host!)\
                                \(photoClub!.memberListURL!.path)/
                                """,
                                comment: "Section footer text Portfolios screen"))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                    .font(.subheadline)
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

    private func deleteMembers(section: [MemberPortfolio], indexSet: IndexSet) { // only temporarily deletes a member
        for index in indexSet {
            let memberPortfolio = section[index] // could use map()
            viewContext.delete(memberPortfolio)
        }

        do {
            if viewContext.hasChanges {
                try viewContext.save()
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
                memberPortfolio.photographer.fullName.localizedCaseInsensitiveContains(searchText.wrappedValue) }
        }

        // loosely related task: asynchronously update the thumbnail of any shown photographer
//        for portfolio in filteredPortfolios {
//            Task {
//                FotogroepWaalreApp.antiZombiePinningOfMemberPortfolios.insert(portfolio)
//                await portfolio.refreshFirstImage() // is await really needed? TODO
//            }
//        }
        return filteredPortfolios
    }

}

struct FilteredMemberPortfolios_Previews: PreviewProvider {
    static let predicate = NSPredicate(format: "photographer_.givenName_ = %@", argumentArray: ["Jan"])
    @State static var searchText: String = ""

    static var previews: some View {
        List { // lists are "Lazy" automatically
            FilteredMemberPortfoliosView(predicate: predicate, searchText: $searchText)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
        .navigationBarTitle(Text(String("FilteredMemberPortfoliosView"))) // prevent localization
        .searchable(text: $searchText, placement: .toolbar, prompt: Text("Search names"))
    }
}
