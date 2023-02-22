//
//  MemberPortfoliosView.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 20/06/2021.
//

import SwiftUI

struct MemberPortfolioListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    private var detentsList: Set<PresentationDetent> = [ .fraction(0.5), .fraction(0.70), .fraction(0.90), .large ]

    @State private var showingSettings = false // controls visibility of Settings screen
    @State private var selectedSettingsDetent = PresentationDetent.fraction(0.70) // must be element of detentsList
    @State private var showingReadme = false // controls visibility of Readme screen
    @State private var selectedReadmeDetent = PresentationDetent.fraction(0.70) // must be element of detentsList
    @State private var searchText: String = ""

    @FetchRequest( // is this used? It is replaced by a fetchRequest in Photographers page
        sortDescriptors: [SortDescriptor(\.familyName_, order: .forward)], // deliberately in strange order
        animation: .default)
    private var photographers: FetchedResults<Photographer>

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.priority_, order: .reverse), // highest priority first
                          SortDescriptor(\.name_, order: .forward), // photo clubs are identified by (name, town)
                          SortDescriptor(\.town_, order: .forward)],
        animation: .default)
    private var photoClubs: FetchedResults<PhotoClub>

    @StateObject var model = SettingsViewModel()

    private let toolbarItemPlacement: ToolbarItemPlacement = UIDevice.isIPad ?
        .destructiveAction : // iPad: Search field in toolbar
        .navigationBarTrailing // iPhone: Search field in drawer

    var body: some View {
        List { // lists are automatically "Lazy"
            FilteredMemberPortfoliosView(predicate: model.settings.memberPredicate, searchText: $searchText)
        }
        .listStyle(.plain)
        .refreshable { _ = FGWMembersProvider() } // for pull-to-refresh
        .keyboardType(.namePhonePad)
        .autocapitalization(.none)
        .submitLabel(.done) // currently only works with text fields?
        .disableAutocorrection(true)
        .navigationTitle(String(localized: "Portfolios", comment: "Title of page showing member portfolios"))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {

                Button {
                    if !showingReadme {
                        showingSettings = true
                    }
                } label: {
                    Image("slider.horizontal.3.rectangle")
                        .font(.title)
                        .foregroundStyle(.memberPortfolioColor, .gray, .sliderColor)
                }
                .sheet(isPresented: $showingSettings, content: {
                    SettingsView(settings: $model.settings)
                    // the detents don't do anything on an iPad
                        .presentationDetents(detentsList, selection: $selectedSettingsDetent)
                        .presentationDragIndicator(.visible) // show drag indicator
                    // swiftlint:disable:next unavailable_condition
                    if #available(iOS 16.4, *) {
                        // .presentationCornerRadius(20) // compiler can't handle this yet
                    }
                })

                Button {
                    if !showingSettings {
                        showingReadme = true
                    }
                } label: {
                    Image("info.rectangle")
                        .font(.title)
                        .foregroundStyle(.linkColor, .gray, .white)
                }
                .sheet(isPresented: $showingReadme, content: {
                    ReadmeView()
                    // the detents don't do anything on an iPad
                        .presentationDetents(detentsList, selection: $selectedReadmeDetent)
                        .presentationDragIndicator(.visible) // show drag indicator
                    // swiftlint:disable:next unavailable_condition
                    if #available(iOS 16.4, *) {
                        // .presentationCornerRadius(20) // compiler can't handle this yet
                    }
                })
            }
            ToolbarItemGroup(placement: toolbarItemPlacement) {

                NavigationLink(destination: {
                    PhotoClubListView(predicate: NSPredicate.all)
                }, label: {
                    Image("mappin.ellipse.rectangle")
                        .font(.title)
                        .foregroundStyle(.photoClubColor, .gray, .red)
                })
                .offset(x: 5)

                NavigationLink(destination: {
                    WhoIsWho(searchText: $searchText)
                }, label: {
                    Image("person.text.rectangle.custom")
                        .font(.title)
                        .foregroundStyle(.photographerColor, .gray, .red)
                })
                .padding(0)

            }
        }
        .searchable(text: $searchText, placement: .automatic,
                    // .automatic
                    // .toolbar The search field is placed in the toolbar. To right of person.text.rect.cust
                    // .sidebar The search field is placed in the sidebar of a navigation view. not on iPad
                    // .navigationBarDrawer The search field is placed in an drawer of the navigation bar. OK
                    prompt: Text("Search names", comment:
                                    """
                                    Field at top of Members page that allows the user to \
                                    filter the members based on either given- and family name.
                                    """
                                ))
        .disableAutocorrection(true)
    }

}

struct MemberListView_Previews: PreviewProvider {
    static var previews: some View {
        MemberPortfolioListView()
			.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
