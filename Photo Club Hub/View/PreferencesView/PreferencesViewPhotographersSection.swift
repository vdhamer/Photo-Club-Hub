//
//  PreferencesViewPhotographersSection.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 16/04/2026.
//

import SwiftUI

struct PreferencesViewPhotographersSection: View {
    @Binding var localPreferences: PreferencesStruct

    var body: some View {
        Section(header: Text("Photographers",
                             tableName: "PhotoClubHub.SwiftUI",
                             comment: "In Preferences, section title"),
                content: {
            HStack {
                Image(systemName: "photo.artframe")
                    .foregroundStyle(.gray, .photographerColor, .red)
                Picker(String(localized: "ThumbnailPhotographers",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Picker to display featuredImage or photographerImage"),
                       selection: $localPreferences.preferenceForFeaturedImage) {
                    Text(String(localized: "photographerImage",
                                table: "PhotoClubHub.SwiftUI",
                                comment: "Label of picker item")).tag(true)
                    Text(String(localized: "featuredImage",
                                table: "PhotoClubHub.SwiftUI",
                                comment: "Label of picker item")).tag(false)
                }
            }
        })
   }
}

private struct PreferencesViewPhotSectionPreviewHost: View {
    @StateObject var model = PreferencesViewModel()

    var body: some View {
        NavigationStack {
            List {
                PreferencesViewPhotographersSection(localPreferences: $model.preferences)
            }
        }
    }
}

#Preview {
        PreferencesViewPhotSectionPreviewHost()
}
