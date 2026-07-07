//
//  MainTabView1717.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 04/07/2026.
//

import SwiftUI

@available(iOS, obsoleted: 18.0)
struct MainTabView1717: View {

    private enum TabID { // identifies the 4 tabs, so app can choose which tab to show at startup
        case people, clubs, maps, settings

        var tint: Color { // matches the accent color used on the corresponding screen
            switch self {
            case .people:   .photographerColor
            case .clubs:    .memberPortfolioColor
            case .maps:     .mapsColor
            case .settings: Color(.systemBlue) // the default iOS tab-selection blue
            }
        }
    }

    @StateObject private var settingsModel = SettingsViewModel.shared
    @State private var photographersSearchText = ""
    @State private var selectedTab: TabID = .clubs

    // Updates selectedTab with animations disabled, so the tab bar tint
    // switches instantly instead of briefly crossfading from the previous tab's color.
    private var selectedTabBinding: Binding<TabID> {
        Binding(
            get: { selectedTab },
            set: { newValue in
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) { selectedTab = newValue }
            }
        )
    }

    var body: some View {
        TabView(selection: selectedTabBinding) {
            NavigationStack {
                PhotographersListView1718(searchText: $photographersSearchText)
            }
            .tag(TabID.people)
            .tabItem {
                Label(String(localized: "People",
                             table: "PhotoClubHub.SwiftUI",
                             comment: "Tab bar label for the list of people (photographers)"),
                      systemImage: "person.text.rectangle")
            }

            NavigationStack {
                MemberPortfolioView()
            }
            .tag(TabID.clubs)
            .tabItem {
                Label(String(localized: "Clubs",
                             table: "PhotoClubHub.SwiftUI",
                             comment: "Tab bar label for the club member portfolios list"),
                      systemImage: "person.3")
            }

            NavigationStack {
                OrganizationView()
            }
            .tag(TabID.maps)
            .tabItem {
                Label(String(localized: "Maps",
                             table: "PhotoClubHub.SwiftUI",
                             comment: "Tab bar label for the maps showing organizations"),
                      systemImage: "mappin.and.ellipse")
            }

            SettingsView(settings: $settingsModel.settings)
                .tag(TabID.settings)
                .tabItem {
                    Label(String(localized: "Settings",
                                 table: "PhotoClubHub.SwiftUI",
                                 comment: "Tab bar label for settings"),
                          systemImage: "gearshape")
                }
        }
        .tint(selectedTab.tint) // colors the selected tab bar item to match its screen
    }

}

// MARK: - Preview

// Believe it or not, this preview actually works.

@available(iOS, obsoleted: 18.0)
#Preview {
    MainTabView1717()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
