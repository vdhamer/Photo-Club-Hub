//
//  SettingsViewMapsTestSection.swift
//  Photo Club Hub
//
//  Created by Claude Code guided by Peter van den Hamer on 30/09/2026.
//

#if DEBUG // exists only in builds Xcode installs, so it never reaches the App Store
import SwiftUI

/// Debug-only section of the Settings tab for measuring the Maps screen (#870, #867):
/// chooses how and when a card creates its live map or image, and shows how many live maps were created.
///
/// Changes apply at once, without Save.
/// All text is `verbatim`, which keeps these debug-only strings out of the String Catalog and its translations.
struct SettingsViewMapsTestSection: View {

    @AppStorage(MapsTestMode.storageKey) private var mode = MapsTestMode.defaultValue
    @AppStorage(MapsTestMode.delayStorageKey) private var delayMilliseconds = MapsTestMode.defaultDelayMilliseconds

    private let shared = LiveMapCounter.shared

    var body: some View {
        Section {
            Picker(selection: $mode) {
                Text(verbatim: "Original: no delay & all maps are live").tag(MapsTestMode.original)
                Text(verbatim: "Phase 1: delay").tag(MapsTestMode.phase1Delay)
                Text(verbatim: "Phase 2: delay & static images").tag(MapsTestMode.phase2Snapshot)
            } label: {
                Text(verbatim: "Maps test mode")
            }

            Picker(selection: $delayMilliseconds) {
                ForEach(MapsTestMode.delayChoicesMilliseconds, id: \.self) { milliseconds in
                    Text(verbatim: "\(milliseconds) ms").tag(milliseconds)
                }
            } label: {
                Text(verbatim: "Delay")
            }
            .disabled(mode == .original) // Original has no delay

            LabeledContent {
                Text(verbatim: "\(shared.created)")
            } label: {
                Text(verbatim: "Live maps created")
            }

            LabeledContent {
                Text(verbatim: "\(shared.maxAtOnce)")
            } label: {
                Text(verbatim: "Max observed simultaneous live maps")
            }

            Button {
                shared.reset()
            } label: {
                Text(verbatim: "Reset counters")
            }
        } header: {
            Text(verbatim: "Debug: Maps scrolling test (#870, #867)")
        }
    }
}

// MARK: - Previews

// Believe it or not, this Preview actually works

#Preview {
    NavigationStack {
        List {
            SettingsViewMapsTestSection()
        }
    }
}
#endif
