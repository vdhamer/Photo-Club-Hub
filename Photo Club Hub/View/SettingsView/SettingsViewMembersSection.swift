//
//  SettingsViewMembersSection.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 15/04/2026.
//

import SwiftUI

struct SettingsViewMembersSection: View {
    @Binding var localSettings: SettingsStruct

    var body: some View {
        Section(header: Text("Clubs screen",
                             tableName: "PhotoClubHub.SwiftUI",
                             comment: "In Preferences, above toggles like \"Show former members\""),
                content: {
            HStack {
                RoleStatusIconView(memberStatus: .current)
                    .foregroundColor(.memberPortfolioColor)
                Toggle(String(localized: "Show current members",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $localSettings.showCurrentMembers.animation())
            }
            if localSettings.showCurrentMembers == false {
                HStack {
                    RoleStatusIconView(memberRole: .viceChairman)
                        .foregroundColor(.deceasedColor)
                    Toggle(String(localized: "Show club officers",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Preferences"),
                           isOn: $localSettings.showOfficers)
                }
            } else {
                HStack {
                    RoleStatusIconView(memberRole: .viceChairman)
                        .foregroundColor(.deceasedColor)
                    Text("“Current members” includes “club officers”",
                         tableName: "PhotoClubHub.SwiftUI",
                         comment: "Shown when \"Show club officers\" entry is missing in Preferences")
                    .foregroundColor(.gray)
                }
            }
            HStack {
                RoleStatusIconView(memberStatus: .prospective)
                    .foregroundColor(.memberPortfolioColor)
                Toggle(String(localized: "Show aspiring members",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $localSettings.showAspiringMembers)
            }
            HStack {
                RoleStatusIconView(memberStatus: .honorary)
                    .foregroundColor(.memberPortfolioColor)
                Toggle(String(localized: "Show honorary members",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $localSettings.showHonoraryMembers)
            }
            HStack {
                RoleStatusIconView(memberStatus: .former)
                    .foregroundColor(.memberPortfolioColor)
                Toggle(String(localized: "Show former members",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $localSettings.showFormerMembers.animation())
            }
            if localSettings.showFormerMembers == false {
                HStack { // moving this outside the if() works but gives a boring animation
                    RoleStatusIconView(memberStatus: .deceased)
                        .foregroundColor(.deceasedColor)
                    Toggle(String(localized: "Show deceased members",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Preferences"),
                           isOn: $localSettings.showDeceasedMembers)
                }
            } else {
                HStack {
                    RoleStatusIconView(memberStatus: .deceased)
                        .foregroundColor(.deceasedColor)
                    Text(
                        "“Former members” includes “deceased members”",
                        tableName: "PhotoClubHub.SwiftUI",
                        comment: "Shown when \"Show deceased members\" entry is missing in Preferences")
                    .foregroundColor(.gray)
                }
            }
            HStack {
                RoleStatusIconView(memberStatus: .coach)
                    .foregroundColor(.memberPortfolioColor)
                Toggle(String(localized: "Show external coaches",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $localSettings.showExternalCoaches)
            }
            SettingsViewThumbnail(localSettings: $localSettings)
        }) // end of section
    } // end of body
}

// MARK: - Previews

// Believe it or not, the following Preview actually works.
private struct SettingsViewMembersSectionPreviewHost: View {
    @StateObject var model = SettingsViewModel()

    var body: some View {
        NavigationStack {
            List {
                SettingsViewMembersSection(localSettings: $model.settings)
            }
        }
    }
}

#Preview {
    SettingsViewMembersSectionPreviewHost()
}
