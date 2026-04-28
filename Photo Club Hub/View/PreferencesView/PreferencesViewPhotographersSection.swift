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
            PreferencesViewThumbnail(localPreferences: $localPreferences)
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

// Believe it or not, the following Preview actually works
#Preview {
        PreferencesViewPhotSectionPreviewHost()
}
