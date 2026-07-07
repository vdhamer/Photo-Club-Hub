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
        case photographers, members, maps, settings
    }

    @StateObject private var preferencesModel = PreferencesViewModel.shared
    @State private var photographersSearchText = ""
    @State private var selectedTab: TabID = .members

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(String(localized: "Photographers",
                       table: "PhotoClubHub.SwiftUI",
                       comment: "Tab bar label for the photographers list"),
                systemImage: "person.text.rectangle",
                value: .photographers) {
                NavigationStack {
                    if #available(iOS 26, *) {
                        PhotographersListView2627(searchText: $photographersSearchText)
                    } else {
                        PhotographersListView1718(searchText: $photographersSearchText)
                    }
                }
            }

            Tab(String(localized: "Members",
                       table: "PhotoClubHub.SwiftUI",
                       comment: "Tab bar label for the member portfolios list"),
                systemImage: "person.2",
                value: .members) {
                NavigationStack {
                    MemberPortfolioView()
                }
            }

            Tab(String(localized: "Maps",
                       table: "PhotoClubHub.SwiftUI",
                       comment: "Tab bar label for the maps showing organizations"),
                systemImage: "mappin.and.ellipse",
                value: .maps) {
                NavigationStack {
                    OrganizationView()
                }
            }

            Tab(String(localized: "Settings",
                       table: "PhotoClubHub.SwiftUI",
                       comment: "Tab bar label for settings"),
                systemImage: "gearshape",
                value: .settings) {
                PreferencesView(preferences: $preferencesModel.preferences)
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabBarMinimizeBehaviorIfAvailable()
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
