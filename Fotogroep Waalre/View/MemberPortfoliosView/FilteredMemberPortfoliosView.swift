//
//  FilteredMemberPortfoliosView.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 29/12/2021.
//

import SwiftUI

struct FilteredMemberPortfoliosView: View {

    @Environment(\.managedObjectContext) private var viewContext
    
    @SectionedFetchRequest<String, MemberPortfolio>(
        sectionIdentifier: \.photoClub_!.fullNameCommaTown,
        sortDescriptors: [],
        predicate: NSPredicate.none
    ) private var sectionedFilteredPortfolios: SectionedFetchResults<String, MemberPortfolio> // TODO: rename

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
        _sectionedFilteredPortfolios = SectionedFetchRequest(
            sectionIdentifier: \.photoClub_!.fullNameCommaTown,
            sortDescriptors: sortDescriptors,
            predicate: predicate,
            animation: .default)
        self.searchText = searchText
    }

    var body: some View {
        let copyFilteredPhotographerFetchResult = sectionedFilteredPortfolios
        ForEach(copyFilteredPhotographerFetchResult) {section in
//            VStack {
                Section {
                    ForEach(filterPortfolios(unFilteredPortfolios: section), id: \.id) { filteredMember in
                        MemberPortfolioRow(member: filteredMember)
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
                           listName: section.id)
                }// }
                .listRowSeparator(.hidden)
//                .padding()
//                .background(Color(.secondarySystemBackground)) // compatible with light and dark mode
//                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 25.0, height: 25.0)))
        }
        if sectionedFilteredPortfolios.nsPredicate == NSPredicate.none {
            Text("""
                 Warning: all member categories on the Preferences page are disabled. \
                 Please enable one or more options in Preferences.
                 """, comment: "Hint to the user if all of the Preference toggles are disabled.")
        } // TODO
//        } else if searchText.wrappedValue != "" && copyFilteredPhotographerFetchResult.isEmpty {
//            Text("""
//                 To see names here, please adapt the Search filter \
//                 or enable additional categories on the Preferences page.
//                 """, comment: "Hint to the user if the database returns zero Members with Search filter in use.")
//        } else if searchText.wrappedValue == "" && copyFilteredPhotographerFetchResult.isEmpty {
//            Text("""
//                 To see names here, please enable additional categories on the Preferences page.
//                 """, comment: "Hint to the user if the database returns zero Members with unused Search filter.")
//        }
    }

    private struct Header: View {
        @Environment(\.colorScheme) private var colorScheme // to detect dark mode
        var title: String

        var body: some View {
            HStack {
                Spacer()
                ZStack {
                    Capsule(style: .continuous)
                        .fill(Gradient(colors: [.memberPortfolioColor.opacity(0.3),
                                                .memberPortfolioColor.opacity(0.1),
                                                .memberPortfolioColor.opacity(0.2),
                                                .memberPortfolioColor.opacity(0.3)]))
                        .frame(maxWidth: 400, alignment: .center)
                    Text(title) // String used to group the elements into Sections
                        .font(.title2)
                        .lineLimit(1)
                        .foregroundColor(colorScheme == .dark ? .memberPortfolioColor : .primary)
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
        static let comment: StaticString = "Statistics at end of section of FilteredMemberPortfoliosView"
        let portfolio = String(localized: "portfolio", comment: comment)
        let portfolios = String(localized: "portfolios", comment: comment)
        let shownFor = String(localized: "shown for")

        var body: some View {
            HStack {
                Spacer()
                Text(filtCount < unfiltCount ?
                     "\(filtCount) (of \(unfiltCount)) \(filtCount==1 ? portfolio : portfolios) \(shownFor)" :
                     " \(listName) \(unfiltCount) \(unfiltCount==1 ? portfolio : portfolios) \(shownFor) \(listName)",
                     comment: FilteredMemberPortfoliosView.Footer.comment)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }

    private func makeFooterString(count: Int) -> String {
        let singular = String(localized: "One portfolio shown", comment: "Header of section of Portfolios screen")
        let plural = String(localized: "\(count) portfolios shown", comment: "Header of section of Portfolios screen")
        return count==1 ? singular : plural
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
            fatalError("Unresolved error deleting members \(nsError), \(nsError.userInfo)")
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
        for portfolio in filteredPortfolios {
            Task {
                FotogroepWaalreApp.antiZombiePinningOfMemberPortfolios.insert(portfolio)
                await portfolio.refreshFirstImage() // is await really needed?
            }
        }
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
