//
//  SettingsViewMapsSection.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 16/04/2026.
//

import SwiftUI
import SemanticColorPicker // for SemanticColor and SemanticColorPicker

struct SettingsViewMapsSection: View {
    @Binding var localSettings: SettingsStruct

    var body: some View {
        Section(header: Text("Maps",
                             tableName: "PhotoClubHub.SwiftUI",
                             comment: "In Settings, section title above map-related toggles"),
                content: {

            HStack { // SHOW CLUBS
                Image(systemName: "mappin.square")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.mapsColor, .gray, .red)
                Toggle(String(localized: "Show clubs",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $localSettings.showClubs.animation())
            }

            HStack { // SHOW TEMPLATE CLUBS
                Image(systemName: "mappin.square")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.mapsColor, .gray, .red)
                Toggle(String(localized: "Show template clubs",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $localSettings.showTemplateClubs.animation())
            }

            HStack { // SHOW MUSEUMS
                Image(systemName: "mappin.square")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.mapsColor, .gray, .red)
                Toggle(String(localized: "Show museums",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $localSettings.showMuseums.animation())
            }

            if localSettings.highlightNonFotobondNL == false {
                HStack { // HIGHLIGHT FOTOBOND
                    Image(systemName: "mappin.square")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.mapsColor, .gray, .red)
                    Toggle(String(localized: "Highlight Dutch Fotobond NL clubs",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Preferences"),
                           isOn: $localSettings.highlightFotobondNL.animation())
                }
            } else {
                HStack {
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

            if localSettings.highlightFotobondNL == false {
                HStack { // HIGHLIGHT NON-FOTOBOND
                    Image(systemName: "mappin.square")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.mapsColor, .gray, .red)
                    Toggle(String(localized: "Highlight non-Fotobond NL clubs",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Preferences"),
                           isOn: $localSettings.highlightNonFotobondNL.animation())
                }
            } else {
                HStack {
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

            let highlightIsUsed = localSettings.highlightFotobondNL ||
                                  localSettings.highlightNonFotobondNL
            if highlightIsUsed {
                HStack {
                    Image(systemName: "mappin.square")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.mapsColor, .gray, .red)
                    SemanticColorPicker(
                        String(localized: "Highlighting color",
                               table: "PhotoClubHub.SwiftUI",
                               comment: "Label of color picker in Preferences"),
                        data: SemanticColor.palette,
                        selection: $localSettings.highlightColor)
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
                SettingsViewMapsSection(localSettings: $model.settings)
            }
        }
    }
}

// Believe it or not, the following Preview actually works.
#Preview {
    SettingsViewMapSectionPreviewHost()
}
