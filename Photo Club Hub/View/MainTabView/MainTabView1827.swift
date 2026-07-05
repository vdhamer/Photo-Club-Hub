//
//  MainTabView1827.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 04/07/2026.
//

import SwiftUI

@available(iOS 18.0, *)
struct MainTabView1827: View { // Tab() needs iOS 18+; .tabBarMinimizeBehavior & PhotographersListView2627 need iOS 26

    @StateObject private var preferencesModel = PreferencesViewModel.shared
    @State private var photographersSearchText = ""

    var body: some View {
        TabView {
            Tab(String(localized: "Photographers",
                       table: "PhotoClubHub.SwiftUI",
                       comment: "Tab bar label for the photographers list"),
                systemImage: "person.text.rectangle") {
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
                systemImage: "person.2") {
                NavigationStack {
                    MemberPortfolioView()
                }
            }

            Tab(String(localized: "Organizations",
                       table: "PhotoClubHub.SwiftUI",
                       comment: "Tab bar label for the organizations list"),
                systemImage: "mappin.and.ellipse") {
                NavigationStack {
                    OrganizationView()
                }
            }

            Tab(String(localized: "Preferences",
                       table: "PhotoClubHub.SwiftUI",
                       comment: "Tab bar label for preferences"),
                systemImage: "gearshape") {
                PreferencesView(preferences: $preferencesModel.preferences)
            }
        }
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
