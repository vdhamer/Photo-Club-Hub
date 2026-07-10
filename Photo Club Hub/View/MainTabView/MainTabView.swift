//
//  MainTabView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 04/07/2026.
//

import SwiftUI

/// Thin dispatcher: shows `MainTabView1827` on iOS 18+ and `MainTabView1717` on iOS 17.
/// Matches the pattern used by `PhotoClubHubApp` to dispatch between `PreludeView1718`/`2627`.
struct MainTabView: View {
    var body: some View {
        if #unavailable(iOS 18) {
            MainTabView1717() // App doesn't support versions before iOS 17
        } else {
            MainTabView1827()
        }
    }
}

// MARK: - Preview

// Believe it or not, this preview actually works.

#Preview {
    MainTabView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
