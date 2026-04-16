//
//  PreferencesViewBody.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 15/04/2026.
//

import SwiftUI
import SemanticColorPicker // for SemanticColor and SemanticColorPicker itself

struct PreferencesView: View {

    @Binding var preferences: PreferencesStruct
    @State private var localPreferences = PreferencesStruct.defaultValue // parameters for various Toggles()

    private let title = String(localized: "Preferences",
                               table: "PhotoClubHub.SwiftUI",
                               comment: "Title of screen with toggles to adjust preferences")

    var body: some View {
        NavigationStack {
            List {
                PreferencesViewMembersSection(localPreferences: $localPreferences)
                PreferencesViewOrganizationsSection(localPreferences: $localPreferences)
                PreferencesViewPhotographersSection(localPreferences: $localPreferences)
                PreferencesViewAdvancedSection(localPreferences: $localPreferences)
            }
            .navigationTitle(title)
        }
        .onDisappear {
            // need to update Bindings for showPhotoClubsList etc
            preferences = localPreferences
        }
    }
}

private struct PreferencesViewPreviewHost: View {
    @StateObject var model = PreferencesViewModel()

    var body: some View {
        PreferencesView(preferences: $model.preferences)
    }
}

#Preview {
    PreferencesViewPreviewHost()
}
