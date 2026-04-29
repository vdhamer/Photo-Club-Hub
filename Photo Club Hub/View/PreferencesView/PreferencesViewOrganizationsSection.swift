//
//  PreferencesViewOrganizationsSection.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 16/04/2026.
//

import SwiftUI
import SemanticColorPicker // for SemanticColor and SemanticColorPicker

struct PreferencesViewOrganizationsSection: View {
    @Binding var localPreferences: PreferencesStruct

    var body: some View {
        Section(header: Text("Organizations",
                             tableName: "PhotoClubHub.SwiftUI",
                             comment: "In Preferences, section title"),
                content: {

            HStack { // SHOW CLUBS
                Image(systemName: "mappin.square")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.organizationColor, .gray, .red)
                Toggle(String(localized: "Show clubs",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $localPreferences.showClubs.animation())
            }

            HStack { // SHOW TEMPLATE CLUBS
                Image(systemName: "mappin.square")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.organizationColor, .gray, .red)
                Toggle(String(localized: "Show template clubs",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $localPreferences.showTemplateClubs.animation())
            }

            HStack { // SHOW MUSEUMS
                Image(systemName: "mappin.square")
                    .font(.title2)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.organizationColor, .gray, .red)
                Toggle(String(localized: "Show museums",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $localPreferences.showMuseums.animation())
            }

            if localPreferences.highlightNonFotobondNL == false {
                HStack { // HIGHLIGHT FOTOBOND
                    Image(systemName: "mappin.square")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.organizationColor, .gray, .red)
                    Toggle(String(localized: "Highlight Dutch Fotobond NL clubs",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Preferences"),
                           isOn: $localPreferences.highlightFotobondNL.animation())
                }
            } else {
                HStack {
                    Image(systemName: "mappin.square")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.organizationColor, .gray, .red)
                    Text(
                        "Highlighting of non-Fotobond clubs already enabled",
                        tableName: "PhotoClubHub.SwiftUI",
                        comment: "Shown when highlightNonFotobondNL toggle is enabled")
                        .foregroundColor(.gray)
                }
            }

            if localPreferences.highlightFotobondNL == false {
                HStack { // HIGHLIGHT NON-FOTOBOND
                    Image(systemName: "mappin.square")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.organizationColor, .gray, .red)
                    Toggle(String(localized: "Highlight non-Fotobond NL clubs",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Preferences"),
                           isOn: $localPreferences.highlightNonFotobondNL.animation())
                }
            } else {
                HStack {
                    Image(systemName: "mappin.square")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.organizationColor, .gray, .red)
                    Text(
                        "Highlighting of Fotobond clubs already enabled",
                        tableName: "PhotoClubHub.SwiftUI",
                        comment: "Shown when highlightFotobondNL toggle is enabled")
                        .foregroundColor(.gray)
                }
            }

            let highlightIsUsed = localPreferences.highlightFotobondNL ||
                                  localPreferences.highlightNonFotobondNL
            if highlightIsUsed {
                HStack {
                    Image(systemName: "mappin.square")
                        .font(.title2)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.organizationColor, .gray, .red)
                    SemanticColorPicker(
                        String(localized: "Highlighting color",
                               table: "PhotoClubHub.SwiftUI",
                               comment: "Label of color picker in Preferences"),
                        data: SemanticColor.palette,
                        selection: $localPreferences.highlightColor)
                }
            }
        }) // end of section
    } // end of body
}

private struct PreferencesViewOrgSectionPreviewHost: View {
    @StateObject var model = PreferencesViewModel()

    var body: some View {
        NavigationStack {
            List {
                PreferencesViewOrganizationsSection(localPreferences: $model.preferences)
            }
        }
    }
}

// Believe it or not, the following Preview actually works
#Preview {
    PreferencesViewOrgSectionPreviewHost()
}
