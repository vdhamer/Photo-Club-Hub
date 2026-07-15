//
//  MainTabView1827.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 04/07/2026.
//

import SwiftUI

@available(iOS 18.0, *)
struct MainTabView1827: View { // Tab() needs iOS 18+; .tabBarMinimizeBehavior & PhotographersListView2627 need iOS 26

    private enum TabID { // identifies the 4 tabs, so app can choose which tab to show at startup
        case maps, clubs, people, settings // tab bar order matches how the Readme introduces the screens (#773)

        var tint: Color { // matches the accent color used on the corresponding screen
            switch self {
            case .maps:     .mapsColor
            case .clubs:    .memberPortfolioColor
            case .people:   .photographerColor
            case .settings: .settingsColor // sepia; distinct from other tabs, gray toggles, and selection blue
            }
        }
    }

    @StateObject private var settingsModel = SettingsViewModel.shared
    @State private var personSearchText = ""
    @State private var selectedTab: TabID = .clubs // which tab is selected when the app is launched

    // Updates selectedTab with animations disabled so the tab bar's selected-icon tint
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
            Tab(String(localized: "Maps",
                       table: "PhotoClubHub.SwiftUI",
                       comment: "Tab bar label for the maps showing organizations"),
                systemImage: "mappin.and.ellipse",
                value: .maps) {
                NavigationStack {
                    MapsView()
                }
                .tint(TabID.maps.tint)
            }

            Tab(String(localized: "Clubs",
                       table: "PhotoClubHub.SwiftUI",
                       comment: "Tab bar label for the club member portfolios list"),
                systemImage: "person.3",
                value: .clubs) {
                NavigationStack {
                    MemberPortfolioView()
                }
                .tint(TabID.clubs.tint)
            }

            Tab(String(localized: "People",
                       table: "PhotoClubHub.SwiftUI",
                       comment: "Tab bar label for the list of people (photographers)"),
                systemImage: "person.text.rectangle",
                value: .people) {
                NavigationStack {
                    if #available(iOS 26, *) {
                        PhotographersListView2627(searchText: $personSearchText)
                    } else {
                        PhotographersListView1718(searchText: $personSearchText)
                    }
                }
                .tint(TabID.people.tint)
            }

            Tab(String(localized: "Settings",
                       table: "PhotoClubHub.SwiftUI",
                       comment: "Tab bar label for settings"),
                systemImage: "gearshape",
                value: .settings) {
                SettingsView(settings: $settingsModel.settings)
                    .tint(TabID.settings.tint)
            }

        }
        .tabViewStyle(.sidebarAdaptable)
        .tabBarMinimizeBehaviorIfAvailable()
        .tint(selectedTab.tint) // colors selected tab bar item; sidebar ignores this for its background (Liquid Glass)
    }

}

private extension View {
    @ViewBuilder
    func tabBarMinimizeBehaviorIfAvailable() -> some View {
        if #available(iOS 26, *) {
            self.tabBarMinimizeBehavior(.onScrollDown)
        } else {
            self
        }
    }

}

// MARK: - Preview

// Believe it or not, this preview actually works.

@available(iOS 18.0, *)
#Preview {
    MainTabView1827()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
