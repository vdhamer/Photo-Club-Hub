//
//  SettingsViewPhotographersSection.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 16/04/2026.
//

import SwiftUI

struct SettingsViewPhotographersSection: View {
    @Binding var localSettings: SettingsStruct

    var body: some View {
        Section(header: Text("People screen",
                             tableName: "PhotoClubHub.SwiftUI",
                             comment: "In Preferences, section title"),
                content: {
            SettingsViewThumbnail(localSettings: $localSettings)
        })
   }
}

private struct SettingsViewPhotSectionPreviewHost: View {
    @StateObject var model = SettingsViewModel()

    var body: some View {
        NavigationStack {
            List {
                SettingsViewPhotographersSection(localSettings: $model.settings)
            }
        }
    }
}

// MARK: - Previews

// Believe it or not, the following Preview actually works.
#Preview {
        SettingsViewPhotSectionPreviewHost()
}
