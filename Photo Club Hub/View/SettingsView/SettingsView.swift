//
//  SettingsView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 15/04/2026.
//

import SwiftUI
import SemanticColorPicker // for SemanticColor and SemanticColorPicker itself

struct SettingsView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.isPresented) private var isSheet // false when hosted in a tab, true when hosted in a sheet

    @Binding var settings: SettingsStruct // parameters for various Toggles()
    @State private var localSettings: SettingsStruct
    @State private var isDirty = false // for tracking changes to localSettings

    private let title = String(localized: "Settings",
                               table: "PhotoClubHub.SwiftUI",
                               comment: "Title of the in-app Settings tab")

    init(settings: Binding<SettingsStruct>) {
        _settings = settings // set binding
        localSettings = settings.wrappedValue
    }

    var body: some View {
        NavigationStack {
            List {
                SettingsViewPhotographersSection(localSettings: $localSettings)
                SettingsViewMembersSection(localSettings: $localSettings)
                SettingsViewMapsSection(localSettings: $localSettings)
                SettingsViewAdvancedSection(localSettings: $localSettings)
            }
            .navigationTitle(title)
            // #776: Settings has no async content, so it is capture-ready as soon as it appears.
            .onAppear { ScreenshotReadiness.signalReady(for: "Settings") }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    if isDirty {
                        Button(String(localized: "Save",
                                      table: "PhotoClubHub.SwiftUI",
                                      comment: "Apply preference changes and dismiss")
                        ) {
                            settings = localSettings // this is where state of Preferences is persisted
                            localSettings = settings // sync back in case setter normalized prefs → isDirty clears
                            dismiss()
                        }
                        .buttonStyle(BorderedProminentButtonStyle())
                        .controlSize(.small)
                    } else if isSheet { // Done only dismisses, so it is pointless when hosted in a tab
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
                        localSettings = settings // discard local changes
                        dismiss() // no-op when hosted in a tab
                    }
                    .onChange(of: localSettings) { _, newValue in
                        isDirty = newValue != settings // SettingsStruct is Equatable
                    }
                    .onChange(of: settings) { _, newValue in
                        isDirty = localSettings != newValue
                    }
                    .disabled(isDirty == false)
                }

                ToolbarItem(placement: .secondaryAction) {
                    Button(String(localized: "Reset to defaults",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Button to reset preferences to original settings")
                    ) {
                        localSettings = SettingsStruct.defaultValue // update UI immediately
                        settings = SettingsStruct.defaultValue // persist the defaults
                    }
                }
            }
            .animation(.easeOut(duration: 0.75), value: isDirty)
            .controlSize(.small)
        }
    }
}

// MARK: - Previews

// Believe it or not, the following Preview actually works.

private struct SettingsViewPreviewHost: View {
    @StateObject var model = SettingsViewModel()

    var body: some View {
        SettingsView(settings: $model.settings)
    }
}

#Preview {
    SettingsViewPreviewHost()
}
