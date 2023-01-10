//
//  MemberPortfoliosView.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 20/06/2021.
//

import SwiftUI

struct MemberPortfoliosView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingFilterSettings = false // controls visibility of Settings screen
    @State private var showingReadme = false // controls visibility of Readme screen
    @State private var searchText: String = ""

    @FetchRequest( // is this used? It is replaced by a fetchRequest in Photographers page
        sortDescriptors: [SortDescriptor(\.familyName_, order: .forward)], // deliberately in strange order
        animation: .default)
    private var photographers: FetchedResults<Photographer>

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.name_, order: .forward)],
        animation: .default)
    private var photoClubs: FetchedResults<PhotoClub>

    @StateObject var model = SettingsViewModel()

    private let toolbarItemPlacement: ToolbarItemPlacement = UIDevice.isIPad ?
        .destructiveAction : // iPad: Search field in toolbar
        .navigationBarTrailing // iPhone: Search field in drawer

    var body: some View {
        GeometryReader { geo in
            List { // lists are automatically "Lazy"
                FilteredMemberPortfoliosView(predicate: model.settings.memberPredicate, searchText: $searchText)
            }
            .refreshable { // for pull-to-refresh
                _ = FGWMembersProvider()
            }
            .keyboardType(.namePhonePad)
            .autocapitalization(.none)
            .submitLabel(.done) // currently only works with text fields?
            .disableAutocorrection(true)
            .navigationTitle(String(localized: "Portfolios", comment: "Title of page showing member portfolios"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {

                    Button {
                        if !showingReadme {
                            showingFilterSettings = true
                        }
                    } label: {
                        Image("slider.horizontal.3.rectangle")
                            .font(.title)
                            .foregroundStyle(.memberColor, .gray, .sliderColor)
                    }
                    .popover(isPresented: $showingFilterSettings,
                             attachmentAnchor: .rect(.bounds),
                             arrowEdge: .top, // ignored in iOS
                             content: {
                        SettingsView(settings: $model.settings)
                            .frame(minWidth: geo.size.width * 0.2,
                                   idealWidth: geo.size.width * 0.45,
                                   maxWidth: geo.size.width * 1.0,
                                   minHeight: geo.size.height * 0.3,
                                   idealHeight: 485,
                                   maxHeight: .infinity
                            )
                    })
                    .padding(Edge.Set.trailing, 5)

                    Button {
                        if !showingFilterSettings {
                            showingReadme = true
                        }
                    } label: {
                        Image("info.rectangle")
                            .font(.title)
                            .foregroundStyle(.linkColor, .gray, .white)
                    }
                    .popover(isPresented: $showingReadme,
                             attachmentAnchor: .rect(.bounds),
                             arrowEdge: .top, // ignored in iOS
                             content: {
                        ReadmeView()
                            .frame(minWidth: geo.size.width * 0.2,
                                   idealWidth: min(800, geo.size.width * 0.9),
                                   maxWidth: geo.size.width * 1,

                                   minHeight: geo.size.height * 0.35,
                                   idealHeight: min(835, geo.size.height * 0.9)
                            )
                    })
                    .offset(x: -5)

                }
                ToolbarItemGroup(placement: toolbarItemPlacement) {

                    NavigationLink(destination: {
                        PhotoClubsView(predicate: NSPredicate.all)
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

}

struct MemberListView_Previews: PreviewProvider {
    static var previews: some View {
        MemberPortfoliosView()
			.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
