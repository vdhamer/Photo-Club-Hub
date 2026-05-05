//
//  MemberPortfoliosView1718.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 20/06/2021.
//

import SwiftUI

/// A list-based view that displays member portfolios with search and toolbar actions.
/// This particular "1718" view is only used for iOS 18 or lower.
///
/// - Presents a `FilteredMemberPortfoliosView2626` inside a SwiftUI `List`.
/// - Supports pull-to-refresh to delete and then reimport Core Data entities.
/// - Provides toolbar buttons to open Preferences and Readme documentation in sheets, and
///   to navigate to Organizations and Photographers lists.
/// - Uses a search field to filter members by name or by expertise..
///
/// This particular "2626" view targets iOS 26 for Liquid Glass APIs and
/// depends somewhat on whether the device is iPad or iPhone.

@available(iOS, obsoleted: 19.0, message: "Please use 'MemberPortfolioView2626' for versions about iOS 18.x")
struct MemberPortfolioView1718: View {
    @Environment(\.managedObjectContext) private var viewContext

    /// Available sheet detents shared by Preferences and Readme sheets.
    private var detentsList: Set<PresentationDetent> = [ .large, .fraction(0.70) ]

    /// Controls visibility of the Preferences sheet.
    @State private var showingPreferences = false
    /// Controls visibility of the Readme sheet.
    @State private var showingReadme = false

    /// The currently selected detent for the Preferences sheet; must be contained in `detentsList`.
    @State private var selectedPreferencesDetent = PresentationDetent.large
    /// The currently selected detent for the Readme sheet; must be contained in `detentsList`.
    @State private var selectedReadmeDetent = PresentationDetent.fraction(0.70)

    /// The text bound to the search field used to filter member portfolios.
    @State private var searchText: String = ""

    /// Photographers fetched for cross-page needs; sorting is intentionally atypical.
    @FetchRequest( // is this used? It is replaced by a fetchRequest in Photographers page
        sortDescriptors: [SortDescriptor(\.familyName_, order: .forward)], // deliberately in strange order
        animation: .default)
    private var photographers: FetchedResults<Photographer>

    /// Organizations fetched and sorted with pinned items first, then by name and town.
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.pinned, order: .reverse),
                          SortDescriptor(\.fullName_, order: .forward),
                          SortDescriptor(\.town_, order: .forward)],
        animation: .default)
    private var organizations: FetchedResults<Organization>

    @StateObject var model = PreferencesViewModel()

    /// Toolbar placement that adapts: iPad shows search in the toolbar, iPhone in the drawer. 
    private let toolbarItemPlacement: ToolbarItemPlacement = UIDevice.isIPad ?
        .destructiveAction : .navigationBarTrailing

    var body: some View {
        List { // lists are automatically "Lazy"
            FilteredMemberPortfoliosView1718(memberPredicate: model.preferences.memberPredicate,
                                             searchText: $searchText)
        }
        .listStyle(.plain)
        .refreshable { // for pull-to-refresh
            // Pull-to-refresh: clears pending reset flag, wipes Core Data, and reloads data.
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
        .navigationTitle(String(localized: "Members",
                                table: "PhotoClubHub.SwiftUI",
                                comment: "Title of page showing member portfolios"))
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarLeading) {

                Button {
                    if !showingReadme { // actually currently can't press Preferences button while showingReadme
                        showingPreferences = true
                    }
                } label: {
                    PreferencesIcon()
                }
                // Preferences sheet with shared detents and visual presentation options.
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
                // Readme sheet with shared detents and visual presentation options.
                .sheet(isPresented: $showingReadme, content: {
                    ReadmeView()
                    // the detents don't do anything on an iPad
                        .presentationDetents(detentsList, selection: $selectedReadmeDetent)
                        .presentationBackground(.thickMaterial) // doesn't work yet with ReadmeView
                        .presentationCornerRadius(40) // compiler can't handle this yet
                        .presentationDragIndicator(.visible) // show drag indicator
                })
            }
            ToolbarItemGroup(placement: toolbarItemPlacement) {

                NavigationLink(destination: {
                    OrganizationView()
                }, label: {
                    Image("mappin.ellipse.rectangle")
                        .font(.title)
                        .foregroundStyle(.organizationColor, .gray, .red)
                })
                .offset(x: 5)

                NavigationLink(destination: {
                    PhotographersListView1718(searchText: $searchText)
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

// Unfortunately, the following Preview doesn't work yet.
@available(iOS, obsoleted: 19.0, message: "Please use 'MemberListView2626_Previews' for versions above iOS 18.x")
struct MemberListView1718_Previews: PreviewProvider {
    static var previews: some View {
        MemberPortfolioView1718()
			.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
