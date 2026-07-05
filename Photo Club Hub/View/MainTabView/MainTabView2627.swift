//
//  MainTabView2627.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 04/07/2026.
//

import SwiftUI

@available(iOS 26.0, *)
struct MainTabView2627: View { // uses Tab (iOS 18) and .tabBarMinimizeBehavior (iOS 26)

    @StateObject private var preferencesModel = PreferencesViewModel.shared
    @State private var photographersSearchText = ""

    var body: some View {
        TabView {
            Tab(String(localized: "Members",
                       table: "PhotoClubHub.SwiftUI",
                       comment: "Tab bar label for the member portfolios list"),
                systemImage: "person.2") {
                NavigationStack {
                    MemberPortfolioView()
                }
            }

            Tab(String(localized: "Photographers",
                       table: "PhotoClubHub.SwiftUI",
                       comment: "Tab bar label for the photographers list"),
                systemImage: "person.text.rectangle") {
                NavigationStack {
                    PhotographersListView2627(searchText: $photographersSearchText)
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
        .tabBarMinimizeBehavior(.onScrollDown)
    }

}

// MARK: - Preview

// Believe it or not, this preview actually works.

@available(iOS 26.0, *)
#Preview {
    MainTabView2627()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
