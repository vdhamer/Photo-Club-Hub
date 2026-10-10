//
//  SettingsViewMembersSection.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 15/04/2026.
//

import SwiftUI

struct SettingsViewMembersSection: View {
    @Binding var settings: SettingsStruct

    var body: some View {
        Section(header: Text("Clubs tab",
                             tableName: "PhotoClubHub.SwiftUI",
                             comment: "In Preferences, above toggles like \"Show former members\""),
                content: {
            HStack {
                RoleStatusIconView(memberStatus: .current)
                    .foregroundColor(.clubsColor)
                Toggle(String(localized: "Show current members",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $settings.showCurrentMembers.animation())
            }
            if settings.showCurrentMembers == false {
                HStack {
                    RoleStatusIconView(memberRole: .viceChairman)
                        .foregroundColor(.deceasedColor)
                    Toggle(String(localized: "Show current club officers",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Preferences"),
                           isOn: $settings.showOfficers)
                }
            } else {
                HStack {
                    RoleStatusIconView(memberRole: .viceChairman)
                        .foregroundColor(.deceasedColor)
                    Text("“Current members” includes “current club officers”",
                         tableName: "PhotoClubHub.SwiftUI",
                         comment: "Shown when \"Show current club officers\" entry is missing in Preferences")
                    .foregroundColor(.gray)
                }
            }
            HStack {
                RoleStatusIconView(memberStatus: .prospective)
                    .foregroundColor(.clubsColor)
                Toggle(String(localized: "Show aspiring members",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $settings.showAspiringMembers)
            }
            HStack {
                RoleStatusIconView(memberStatus: .honorary)
                    .foregroundColor(.clubsColor)
                Toggle(String(localized: "Show honorary members",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $settings.showHonoraryMembers)
            }
            HStack {
                RoleStatusIconView(memberStatus: .former)
                    .foregroundColor(.clubsColor)
                Toggle(String(localized: "Show former members",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $settings.showFormerMembers.animation())
            }
            if settings.showFormerMembers == false {
                HStack { // moving this outside the if() works but gives a boring animation
                    RoleStatusIconView(memberStatus: .deceased)
                        .foregroundColor(.deceasedColor)
                    Toggle(String(localized: "Show deceased members",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Preferences"),
                           isOn: $settings.showDeceasedMembers)
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
                    .foregroundColor(.clubsColor)
                Toggle(String(localized: "Show external coaches",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $settings.showExternalCoaches)
            }
            SettingsViewThumbnail(settings: $settings, iconColor: .clubsColor)
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
                SettingsViewMembersSection(settings: $model.settings)
            }
        }
    }
}

#Preview {
    SettingsViewMembersSectionPreviewHost()
}
