//
//  FilteredMemberPortfoliosView.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 29/12/2021.
//

import SwiftUI
import WebKit

struct FilteredMemberPortfoliosView: View {

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest var fetchRequest: FetchedResults<MemberPortfolio>
    var wkWebView = WKWebView()
    let searchText: Binding<String>

    // regenerate Section using current FetchRequest with current filters and sorting
    init(predicate: NSPredicate, searchText: Binding<String>) {
        _fetchRequest = FetchRequest<MemberPortfolio>(sortDescriptors: [ // replaces previous fetchRequest
                                                SortDescriptor(\.photographer_!.givenName_, order: .forward),
                                                SortDescriptor(\.photographer_!.familyName_, order: .forward)
                                            ],
                                             predicate: predicate,
                                             animation: .default
        )
        self.searchText = searchText
    }

    var body: some View {
        ForEach(filteredPhotographerFetchResult, id: \.id) { filteredMember in
            NavigationLink(destination: SinglePortfolioView(url: filteredMember.memberWebsite, webView: wkWebView)
                            .navigationTitle(filteredMember.photographer.fullName)
                            .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)) {
                HStack(alignment: .center) {
                    RoleStatusIconView(memberRolesAndStatus: filteredMember.memberRolesAndStatus)
                        .foregroundStyle(.memberColor, .gray, .red) // red tertiary color should not show up
                        .imageScale(.large)
                        .offset(x: -5, y: 0)
                    VStack(alignment: .leading) {
                        Text(verbatim: "\(filteredMember.photographer.fullName)")
                            .font(UIDevice.isIPad ? .title : .title3)
                            .tracking(1)
                            .allowsTightening(true)
                            .foregroundColor(chooseColor(defaultColor: .accentColor,
                                                         isDeceased: filteredMember.photographer.isDeceased))
                        Text("\(filteredMember.roleDescription) of \(filteredMember.photoClub.name)",
                             comment: "<role1 and role2> of <photoclub>. Note <and> is handled elsewhere.")
                            .truncationMode(.tail)
                            .lineLimit(2)
                            .font(UIDevice.isIPad ? .headline : .subheadline)
                            .foregroundColor(filteredMember.photographer.isDeceased ? .deceasedColor : .primary)
                    }
                    Spacer()
                    AsyncImage(url: filteredMember.latestImageURL) { phase in
                        if let image = phase.image {
                            image // Displays the loaded image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else if phase.error != nil ||
                                  filteredMember.latestImageURL == nil {
                            Image("Orange-question-mark") // Displays image indicating an error occurred
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.red, .yellow, .red) // red tertiary color should not show up
                                .symbolRenderingMode(.palette)
                        } else {
                            Image("Embarrassed-snail") // Displays placeholder while loading
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundStyle(.memberColor, .gray, .red) // red tertiary color should not show up
                                .symbolRenderingMode(.palette)
                        }
                    }
                    .frame(width: 80, height: 80)
                    .clipped()
                    .border(TintShapeStyle() )
                }
            }

        }
            .onDelete(perform: deleteMembers)
            .accentColor(.memberColor)
        if fetchRequest.nsPredicate == NSPredicate.none {
            Text("""
                 Warning: all member categories on the Preferences page are disabled. \
                 Please enable one or more options in Preferences.
                 """, comment: "Hint to the user if all of the Preference toggles are disabled.")
        } else if searchText.wrappedValue != "" && filteredPhotographerFetchResult.isEmpty {
            Text("""
                 To see names here, please adapt the Search filter \
                 or enable additional categories on the Preferences page.
                 """, comment: "Hint to the user if the database returns zero Members.")
        } else if searchText.wrappedValue == "" && filteredPhotographerFetchResult.isEmpty {
            Text("""
                 To see names here, please enable additional categories on the Preferences page.
                 """, comment: "Hint to the user if the database returns zero Members.")
        } else if let photographer=findFirstNonDistinct(memberPortfolios: filteredPhotographerFetchResult) {
            Text("""
                 At least one photographer (\(photographer.fullName)) is listed multiple times here. \
                 This is because such photographers are or were associated with more than one photo club.
                 """, comment: "Shown in gray at the bottom of the Portfolios page.")
                .foregroundColor(.gray)
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

    private func deleteMembers(offsets: IndexSet) { // only temporarily deletes a member, just for show
        offsets.map { fetchRequest[$0] }.forEach( viewContext.delete )

        do {
            if viewContext.hasChanges {
                try viewContext.save()
                print("Deleted member")
            }
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate.
            // You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error deleting members \(nsError), \(nsError.userInfo)")
        }
    }

    private func chooseColor(defaultColor: Color, isDeceased: Bool) -> Color {
        if isDeceased {
            return .deceasedColor
        } else {
            return defaultColor // .primary
        }
    }

    private var filteredPhotographerFetchResult: [MemberPortfolio] {
        if searchText.wrappedValue.isEmpty {
            return fetchRequest.filter { _ in
                true
            }
        } else {
            return fetchRequest.filter { memberPortfolio in
                memberPortfolio.photographer.fullName.localizedCaseInsensitiveContains(searchText.wrappedValue) }
        }
    }

}

struct FilteredMemberPortfolios_Previews: PreviewProvider {
    static let predicate = NSPredicate(format: "photographer_.givenName_ = %@", argumentArray: ["Jan"])
    @State static var searchText: String = ""

    static var previews: some View {
        NavigationView {
            List { // lists are "Lazy" automatically
                FilteredMemberPortfoliosView(predicate: predicate, searchText: $searchText)
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
            .navigationBarTitle(Text(String("FilteredMemberPortfoliosView"))) // prevent localization
        }
        .navigationViewStyle(.stack)
        .searchable(text: $searchText, placement: .toolbar, prompt: Text("Search names"))
    }
}
