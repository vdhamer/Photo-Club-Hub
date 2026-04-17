//
//  PreferencesViewBody.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 15/04/2026.
//

import SwiftUI
import SemanticColorPicker // for SemanticColor and SemanticColorPicker itself

struct PreferencesView: View {

    @Environment(\.dismiss) private var dismiss

    @Binding var preferences: PreferencesStruct // parameters for various Toggles()
    @State private var localPreferences: PreferencesStruct
    @State private var isDirty = false // for tracking changes to localPreferences

    private let title = String(localized: "Preferences",
                               table: "PhotoClubHub.SwiftUI",
                               comment: "Title of screen with toggles to adjust preferences")

    init(preferences: Binding<PreferencesStruct>) {
        _preferences = preferences // set binding
        localPreferences = preferences.wrappedValue
    }

    var body: some View {
        NavigationStack {
            List {
                PreferencesViewMembersSection(localPreferences: $localPreferences)
                PreferencesViewOrganizationsSection(localPreferences: $localPreferences)
                PreferencesViewPhotographersSection(localPreferences: $localPreferences)
                PreferencesViewAdvancedSection(localPreferences: $localPreferences)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Dismiss preferences without applying changes")
                    ) {
                        // Discard local changes and dismiss
                        dismiss()
                    }
                    // .buttonStyle(.bordered) // gives round button on Xcode 26.5 beta 2
                    .onChange(of: localPreferences) { _, newValue in
                        isDirty = newValue != preferences // PreferencesStruct is Equatable
                    }
                    .onChange(of: preferences) { _, newValue in
                        isDirty = localPreferences != newValue
                    }
                    .disabled(isDirty == false)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isDirty ? String(localized: "Save",
                                             table: "PhotoClubHub.SwiftUI",
                                             comment: "Apply preference changes and dismiss") :
                                     String(localized: "Done",
                                            table: "PhotoClubHub.SwiftUI",
                                            comment: "Apply preference changes and dismiss")
                    ) {
                        // Commit changes and dismiss
                        if isDirty {
                            print("""
                                  <\(preferences.showCurrentMembers)> \
                                  <\(localPreferences.showCurrentMembers)> // TODO
                                  """)
                            preferences = localPreferences // this is were state of Preferences is persisted
                        }
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent )
                }
            }
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
