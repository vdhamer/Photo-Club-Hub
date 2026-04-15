//
//  PreferencesViewMembersSection.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 15/04/2026.
//

import SwiftUI

struct PreferencesViewMembersSection: View {
    @Binding var localPreferences: PreferencesStruct

    var body: some View {
        Section(header: Text("Members",
                             tableName: "PhotoClubHub.SwiftUI",
                             comment: "In Preferences, above toggles like \"Show former members\""),
                content: {
            HStack {
                RoleStatusIconView(memberStatus: .current)
                    .foregroundColor(.memberPortfolioColor)
                Toggle(String(localized: "Show current members",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $localPreferences.showCurrentMembers.animation())
            }
            if localPreferences.showCurrentMembers == false {
                HStack {
                    RoleStatusIconView(memberRole: .viceChairman)
                        .foregroundColor(.deceasedColor)
                    Toggle(String(localized: "Show club officers",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Preferences"),
                           isOn: $localPreferences.showOfficers)
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
                       isOn: $localPreferences.showAspiringMembers)
            }
            HStack {
                RoleStatusIconView(memberStatus: .honorary)
                    .foregroundColor(.memberPortfolioColor)
                Toggle(String(localized: "Show honorary members",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $localPreferences.showHonoraryMembers)
            }
            HStack {
                RoleStatusIconView(memberStatus: .former)
                    .foregroundColor(.memberPortfolioColor)
                Toggle(String(localized: "Show former members",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Preferences"),
                       isOn: $localPreferences.showFormerMembers.animation())
            }
            if localPreferences.showFormerMembers == false {
                HStack { // moving this outside the if() works but gives a boring animation
                    RoleStatusIconView(memberStatus: .deceased)
                        .foregroundColor(.deceasedColor)
                    Toggle(String(localized: "Show deceased members",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Preferences"),
                           isOn: $localPreferences.showDeceasedMembers)
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
                       isOn: $localPreferences.showExternalCoaches)
            }
            HStack {
                Image(systemName: "photo.artframe")
                    .foregroundStyle(.gray, .memberPortfolioColor, .red)
                Picker(String(localized: "ThumbnailMembers",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Picker to display featuredImage or photographerImage"),
                       selection: $localPreferences.showPhotographerImage) {
                    Text(String(localized: "photographerImage",
                                table: "PhotoClubHub.SwiftUI",
                                comment: "Label of picker item")).tag(true)
                    Text(String(localized: "featuredImage",
                                table: "PhotoClubHub.SwiftUI",
                                comment: "Label of picker item")).tag(false)
                }
            }
        }) // end of section
    } // end of body
}

private struct PreferencesViewMembersSectionPreviewHost: View {
    @StateObject var model = PreferencesViewModel()

    var body: some View {
        NavigationStack {
            List {
                PreferencesViewMembersSection(localPreferences: $model.preferences)
            }
        }
    }
}

#Preview {
    PreferencesViewMembersSectionPreviewHost()
}
