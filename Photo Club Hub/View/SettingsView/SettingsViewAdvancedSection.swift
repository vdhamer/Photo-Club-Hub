//
//  SettingsViewAdvancedSection.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 16/04/2026.
//

import SwiftUI

struct SettingsViewAdvancedSection: View {
    @Binding var localSettings: SettingsStruct

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
                        Text(UIDevice.isIPad
                             ? String(localized: "iPad Settings",
                                      table: "PhotoClubHub.SwiftUI",
                                      comment: "Link to Photo Club Hub section in iPad Settings app")
                             : String(localized: "iPhone Settings",
                                      table: "PhotoClubHub.SwiftUI",
                                      comment: "Link to Photo Club Hub section in iPhone Settings app"))
                    }
        })
    }
}

private struct SettingsViewAdvSectionPreviewHost: View {
    @StateObject var model = SettingsViewModel()

    var body: some View {
        NavigationStack {
            List {
                SettingsViewAdvancedSection(localSettings: $model.settings)
            }
        }
    }
}

// MARK: - Previews

// Believe it or not, the following Preview actually works.
#Preview {
    SettingsViewAdvSectionPreviewHost()
}
