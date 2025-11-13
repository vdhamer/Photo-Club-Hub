//
//  MemberPortfoliosView1718.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 20/06/2021.
//

import SwiftUI

@available(iOS, obsoleted: 19.0, message: "Please use 'MemberPortfolioListView2626' for versions about iOS 18.x")
struct MemberPortfolioListView1718: View {
    @Environment(\.managedObjectContext) private var viewContext
    private var detentsList: Set<PresentationDetent> = [ .fraction(0.5), .fraction(0.70), .fraction(0.90), .large ]

    @State private var showingPreferences = false // controls visibility of Preferences screen
    @State private var showingReadme = false // controls visibility of Readme screen

    @State private var selectedPreferencesDetent = PresentationDetent.large // must be elem. of detentsList
    @State private var selectedReadmeDetent = PresentationDetent.fraction(0.70) // must be element of detentsList

    @State private var searchText: String = ""

    @FetchRequest( // is this used? It is replaced by a fetchRequest in Photographers page
        sortDescriptors: [SortDescriptor(\.familyName_, order: .forward)], // deliberately in strange order
        animation: .default)
    private var photographers: FetchedResults<Photographer>

    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.pinned, order: .reverse), // pinned first
                          SortDescriptor(\.fullName_, order: .forward), // photo clubs are identified by (name, town)
                          SortDescriptor(\.town_, order: .forward)],
        animation: .default)
    private var organizations: FetchedResults<Organization>

    @StateObject var model = PreferencesViewModel()

    private let toolbarItemPlacement: ToolbarItemPlacement = UIDevice.isIPad ?
        .destructiveAction : // iPad: Search field in toolbar
        .navigationBarTrailing // iPhone: Search field in drawer

    var body: some View {
        List { // lists are automatically "Lazy"
            FilteredMemberPortfoliosView(memberPredicate: model.preferences.memberPredicate, searchText: $searchText)
        }
        .listStyle(.plain)
        .refreshable { // for pull-to-refresh
            // do not remove next statement: a side-effect of reading the flag, is that it clears the flag!
            if Settings.dataResetPending {
                print("dataResetPending flag toggled from true to false")
            }
            Model.deleteAllCoreDataObjects(viewContext: viewContext)
            PhotoClubHubApp.loadClubsAndMembers() // carefull: runs asynchronously
        }
        .keyboardType(.namePhonePad)
        .autocapitalization(.sentences)
        .submitLabel(.done) // currently only works with text fields?
        .disableAutocorrection(true)
        .navigationTitle(String(localized: "Portfolios",
                                table: "PhotoClubHub.SwiftUI",
                                comment: "Title of page showing member portfolios"))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {

                Button {
                    if !showingReadme { // actually currently can't press Preferences button while showingReadme
                        showingPreferences = true
                    }
                } label: {
                    PreferencesIcon1718()
                }
                .sheet(isPresented: $showingPreferences, content: {
                    PreferencesView1718(preferences: $model.preferences)
                    // the detents don't do anything on an iPad
                        .presentationDetents(detentsList, selection: $selectedPreferencesDetent)
                        .presentationBackground(.regularMaterial) // doesn't work yet with PreferencesView
                        .presentationCornerRadius(40)
                        .presentationDragIndicator(.visible) // show drag indicator
                })

                Button {
                    if !showingPreferences { // actually currently can't press Preferences button while showingReadme
                        showingReadme = true
                    }
                } label: {
                    Image("info.rectangle")
                        .font(.title)
                        .foregroundStyle(.linkColor, .gray, .white)
                }
                .sheet(isPresented: $showingReadme, content: {
                    ReadmeView1718()
                    // the detents don't do anything on an iPad
                        .presentationDetents(detentsList, selection: $selectedReadmeDetent)
                        .presentationBackground(.thickMaterial) // doesn't work yet with ReadmeView
                        .presentationCornerRadius(40) // compiler can't handle this yet
                        .presentationDragIndicator(.visible) // show drag indicator
                })
            }
            ToolbarItemGroup(placement: toolbarItemPlacement) {

                NavigationLink(destination: {
                    let predicateAll = NSPredicate(format: "TRUEPREDICATE")
                    OrganizationListView1718(predicate: predicateAll)
                }, label: {
                    Image("mappin.ellipse.rectangle")
                        .font(.title)
                        .foregroundStyle(.organizationColor, .gray, .red)
                })
                .offset(x: 5)

                NavigationLink(destination: {
                    WhoIsWhoListView(searchText: $searchText)
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
                    prompt: Text("Search_names_m",
                                 tableName: "PhotoClubHub.SwiftUI",
                                 comment: """
                                          Field at top of MemberPortfolios page that allows the user to \
                                          filter the members based on either given- and family name.
                                          """
                                ))
        .disableAutocorrection(true)
    }

}

@available(iOS, obsoleted: 19.0, message: "Please use 'MemberListView2626_Previews' for versions above iOS 18.x")
struct MemberListView1718_Previews: PreviewProvider {
    static var previews: some View {
        MemberPortfolioListView1718()
			.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

@available(iOS, obsoleted: 19.0, message: "Please use 'PreferencesIcon2626' for versions above iOS 18.x")
struct PreferencesIcon1718: View {
    @Environment(\.isEnabled) private var isEnabled: Bool

    var body: some View {
        Image("slider.horizontal.3.rectangle")
            .font(.title)
            .foregroundStyle(isEnabled ? .memberPortfolioColor : .gray, // isEnabled is always true :-(
                             .gray,
                             isEnabled ? .sliderColor : .gray)
    }
}
