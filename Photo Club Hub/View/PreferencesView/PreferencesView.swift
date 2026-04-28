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
                ToolbarItem(placement: .confirmationAction) {
                    if isDirty {
                        Button(String(localized: "Save",
                                      table: "PhotoClubHub.SwiftUI",
                                      comment: "Apply preference changes and dismiss")
                        ) {
                            preferences = localPreferences // this is where state of Preferences is persisted
                            dismiss()
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        .controlSize(.small)
                    } else {
                        Button(String(localized: "Done",
                                      table: "PhotoClubHub.SwiftUI",
                                      comment: "Apply preference changes and dismiss")
                        ) {
                            dismiss()
                        }
                        .buttonStyle(BorderedButtonStyle()) // ternary operator doesn't work here
                    }
                }

                ToolbarItem(placement: .secondaryAction) {
                    Button(isDirty ? String(localized: "Cancel",
                                            table: "PhotoClubHub.SwiftUI",
                                            comment: "Dismiss preferences without applying changes") :
                            String(localized: "No changes to undo",
                                   table: "PhotoClubHub.SwiftUI",
                                   comment: "Explanation why Cancel buton is greyed out")
                    ) {
                        // Discard local changes and dismiss
                        dismiss()
                    }
                    .onChange(of: localPreferences) { _, newValue in
                        isDirty = newValue != preferences // PreferencesStruct is Equatable
                    }
                    .onChange(of: preferences) { _, newValue in
                        isDirty = localPreferences != newValue
                    }
                    .disabled(isDirty == false)
                }

                ToolbarItem(placement: .secondaryAction) {
                    Button(String(localized: "Reset to defaults",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Button to reset preferences to original settings")
                    ) {
                        preferences = PreferencesStruct.defaultValue
                        dismiss()
                    }
                }
            }
            .animation(.easeOut(duration: 0.75), value: isDirty)
            .controlSize(.small)
        }
    }
}

// Believe it or not, the following Preview actually works
private struct PreferencesViewPreviewHost: View {
    @StateObject var model = PreferencesViewModel()

    var body: some View {
        PreferencesView(preferences: $model.preferences)
    }
}

#Preview {
    PreferencesViewPreviewHost()
}
