//
//  MainTabView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 04/07/2026.
//

import SwiftUI

/// Thin dispatcher: shows `MainTabView2627` on iOS 26+ and `MainTabView1718` on older versions.
/// Matches the pattern used by `PhotoClubHubApp` to dispatch between `PreludeView1718`/`2627`.
struct MainTabView: View {
    var body: some View {
        if #unavailable(iOS 26) {
            MainTabView1718()
        } else {
            MainTabView2627()
        }
    }
}

// MARK: - Preview

// Believe it or not, this preview actually works.

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
