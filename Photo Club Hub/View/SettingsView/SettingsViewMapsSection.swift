//
//  SettingsViewMapsSection.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 16/04/2026.
//

import SwiftUI
import SemanticColorPicker // for SemanticColor and SemanticColorPicker

struct SettingsViewMapsSection: View {
    @Binding var settings: SettingsStruct

    var body: some View {
        Section(header: Text("Maps tab",
                             tableName: "PhotoClubHub.SwiftUI",
                             comment: "In Settings, section title above map-related toggles"),
                content: {

            HStack(spacing: SettingsView.iconSpacing) { // Show clubs
                Image(systemName: "mappin.square")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.mapsColor, .gray, .red)
                Toggle(String(localized: "Show clubs",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $settings.showClubs.animation())
            }

            HStack(spacing: SettingsView.iconSpacing) { // Show museums
                Image(systemName: "mappin.square")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.mapsColor, .gray, .red)
                Toggle(String(localized: "Show museums",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $settings.showMuseums.animation())
            }

            if settings.highlightNonFotobondNL == false {
                HStack(spacing: SettingsView.iconSpacing) { // Highlight Fotobond clubs
                    Image(systemName: "mappin.square")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.mapsColor, .gray, .red)
                    Toggle(String(localized: "Highlight Dutch Fotobond NL clubs",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Preferences"),
                           isOn: $settings.highlightFotobondNL.animation())
                }
            } else {
                HStack(spacing: SettingsView.iconSpacing) {
                    Image(systemName: "mappin.square")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.mapsColor, .gray, .red)
                    Text(
                        "Highlighting of non-Fotobond clubs already enabled",
                        tableName: "PhotoClubHub.SwiftUI",
                        comment: "Shown when highlightNonFotobondNL toggle is enabled")
                        .foregroundColor(.gray)
                }
            }

            if settings.highlightFotobondNL == false {
                HStack(spacing: SettingsView.iconSpacing) { // Highlight non-Fotobond clubs
                    Image(systemName: "mappin.square")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.mapsColor, .gray, .red)
                    Toggle(String(localized: "Highlight non-Fotobond NL clubs",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Preferences"),
                           isOn: $settings.highlightNonFotobondNL.animation())
                }
            } else {
                HStack(spacing: SettingsView.iconSpacing) {
                    Image(systemName: "mappin.square")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.mapsColor, .gray, .red)
                    Text(
                        "Highlighting of Fotobond clubs already enabled",
                        tableName: "PhotoClubHub.SwiftUI",
                        comment: "Shown when highlightFotobondNL toggle is enabled")
                        .foregroundColor(.gray)
                }
            }

            let highlightIsUsed = settings.highlightFotobondNL ||
                                  settings.highlightNonFotobondNL
            if highlightIsUsed {
                HStack(spacing: SettingsView.iconSpacing) {
                    Image(systemName: "mappin.square")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.mapsColor, .gray, .red)
                    SemanticColorPicker(
                        String(localized: "Highlighting color",
                               table: "PhotoClubHub.SwiftUI",
                               comment: "Label of color picker in Preferences"),
                        data: SemanticColor.palette,
                        selection: $settings.highlightColor)
                }
            }
        }) // end of section
    } // end of body
}

// MARK: - Previews

// Believe it or not, the following Preview actually works.
private struct SettingsViewMapSectionPreviewHost: View {
    @StateObject var model = SettingsViewModel()

    var body: some View {
        NavigationStack {
            List {
                SettingsViewMapsSection(settings: $model.settings)
            }
        }
    }
}

// Believe it or not, the following Preview actually works.
#Preview {
    SettingsViewMapSectionPreviewHost()
}
