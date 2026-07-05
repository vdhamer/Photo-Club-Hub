//
//  MainTabView1717.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 04/07/2026.
//

import SwiftUI

@available(iOS, obsoleted: 18.0)
struct MainTabView1717: View {

    @StateObject private var preferencesModel = PreferencesViewModel.shared
    @State private var photographersSearchText = ""

    var body: some View {
        TabView {
            NavigationStack {
                MemberPortfolioView()
            }
            .tabItem {
                Label(String(localized: "Members",
                             table: "PhotoClubHub.SwiftUI",
                             comment: "Tab bar label for the member portfolios list"),
                      systemImage: "person.2")
            }

            NavigationStack {
                PhotographersListView1718(searchText: $photographersSearchText)
            }
            .tabItem {
                Label(String(localized: "Photographers",
                             table: "PhotoClubHub.SwiftUI",
                             comment: "Tab bar label for the photographers list"),
                      systemImage: "person.text.rectangle")
            }

            NavigationStack {
                OrganizationView()
            }
            .tabItem {
                Label(String(localized: "Organizations",
                             table: "PhotoClubHub.SwiftUI",
                             comment: "Tab bar label for the organizations list"),
                      systemImage: "mappin.and.ellipse")
            }

            PreferencesView(preferences: $preferencesModel.preferences)
                .tabItem {
                    Label(String(localized: "Preferences",
                                 table: "PhotoClubHub.SwiftUI",
                                 comment: "Tab bar label for preferences"),
                          systemImage: "gearshape")
                }
        }
    }

}

// MARK: - Preview

// Believe it or not, this preview actually works.

@available(iOS, obsoleted: 18.0)
#Preview {
    MainTabView1717()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
