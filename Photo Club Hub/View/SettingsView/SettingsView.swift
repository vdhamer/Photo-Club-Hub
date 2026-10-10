//
//  SettingsView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 15/04/2026.
//

import SwiftUI
import SemanticColorPicker // for SemanticColor and SemanticColorPicker itself

struct SettingsView: View {

    // #878: these toggles change `settings` (below) directly, with no working copy and no Save button that commits.
    // It is bound to SettingsViewModel.settings, whose @Published wrapper saves every change to UserDefaults.
    // Previously there was a working copy with a Save button, but users sometimes forgot to Save. Now no longer needed.
    @Binding var settings: SettingsStruct // parameters for various Toggles()
    // Flipped by every tap on "Reset to defaults".
    // Note that true or false state means nothing and is never read:
    // .sensoryFeedback(trigger:) plays the haptic whenever `hapticTriggerOnChange` changes state.
    @State private var hapticTriggerOnChange = false // true would have same behavior (see above)

    private let title = String(localized: "Settings",
                               table: "PhotoClubHub.SwiftUI",
                               comment: "Title of the in-app Settings tab")

    var body: some View {
        NavigationStack {
            List {
                SettingsViewPhotographersSection(settings: $settings)
                SettingsViewMembersSection(settings: $settings)
                SettingsViewMapsSection(settings: $settings)
                SettingsViewAdvancedSection(settings: $settings)
                #if DEBUG
                SettingsViewMapsTestSection() // #870: debug-only test mode for the Maps screen
                #endif
            }
            .navigationTitle(title)
            // #776: Settings has no async content, so it is capture-ready as soon as it appears.
            .onAppear { ScreenshotReadiness.signalReady(for: "Settings") }
            .toolbar {
                // Only shown when there is something to reset, so its disappearing also confirms a reset.
                if settings != SettingsStruct.defaultValue {
                    ToolbarItem(placement: .secondaryAction) {
                        Button(String(localized: "Reset to defaults",
                                      table: "PhotoClubHub.SwiftUI",
                                      comment: "Button to reset preferences to default settings"),
                               systemImage: "arrow.counterclockwise" // partly shown to help fill menu's minimum width
                        ) {
                            // The animation lets changed toggles visibly slide back and dependent rows fold in or out.
                            // The haptic confirms the reset even when the changed toggles are scrolled out of view.
                            withAnimation {
                                settings = SettingsStruct.defaultValue // persisted like any other change
                            }
                            hapticTriggerOnChange.toggle() // trigger haptic to acknowledge "Reset to defaults"
                        }
                    }
                }
            }
            .sensoryFeedback(.success, trigger: hapticTriggerOnChange) // no effect on iPad, which has no haptics
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
