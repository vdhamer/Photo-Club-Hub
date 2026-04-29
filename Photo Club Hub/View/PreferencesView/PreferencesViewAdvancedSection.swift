//
//  PreferencesViewAdvancedSection.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 16/04/2026.
//

import SwiftUI

struct PreferencesViewAdvancedSection: View {
    @Binding var localPreferences: PreferencesStruct

    var body: some View {
        Section(header: Text("Advanced",
                             tableName: "PhotoClubHub.SwiftUI",
                             comment: "In Preferences, above link to Settings"),
                content: {
                    Button {
                        Task { // required for for async call
                            // code matches https://developer.apple.com/videos/play/wwdc2024/10185/
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                await UIApplication.shared.open(url)
                            }
                        }
                    } label: {
                        Text("Options in Settings",
                             tableName: "PhotoClubHub.SwiftUI",
                             comment: "Link to Photo Club Hub section in Settings")
                    }
        })
    }
}

private struct PreferencesViewAdvSectionPreviewHost: View {
    @StateObject var model = PreferencesViewModel()

    var body: some View {
        NavigationStack {
            List {
                PreferencesViewAdvancedSection(localPreferences: $model.preferences)
            }
        }
    }
}

// Believe it or not, the following Preview actually works
#Preview {
    PreferencesViewAdvSectionPreviewHost()
}
