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
        Section(header: Text("Club members",
                             tableName: "PhotoClubHub.SwiftUI",
                             comment: "In Settings, above toggles like \"Show former members\""),
                footer: emptyClubsFooter,
                content: {

            // As in the Organizations section, each icon shows only while its toggle is on: together the icons show
            // which kinds of members the Clubs tab lists, each with the icon it has there.
            // VoiceOver skips the icons: the labels and toggles say it all.
            HStack(spacing: SettingsView.iconSpacing) {
                RoleStatusIconView(memberStatus: .current)
                    .foregroundColor(.clubsColor)
                    .opacity(settings.showCurrentMembers ? 1 : 0)
                    .accessibilityHidden(true)
                Toggle(String(localized: "Show current members",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Settings"),
                       isOn: $settings.showCurrentMembers.animation())
            }

            // Officers are current members, so this row is hidden while current members are shown.
            if !settings.showCurrentMembers {
                HStack(spacing: SettingsView.iconSpacing) {
                    RoleStatusIconView(memberRole: .viceChairman)
                        .foregroundColor(.deceasedColor)
                        .opacity(settings.showOfficers ? 1 : 0)
                        .accessibilityHidden(true)
                    Toggle(String(localized: "Show current club officers",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Settings"),
                           isOn: $settings.showOfficers.animation())
                }
            }

            HStack(spacing: SettingsView.iconSpacing) {
                RoleStatusIconView(memberStatus: .prospective)
                    .foregroundColor(.clubsColor)
                    .opacity(settings.showAspiringMembers ? 1 : 0)
                    .accessibilityHidden(true)
                Toggle(String(localized: "Show aspiring members",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Settings"),
                       isOn: $settings.showAspiringMembers.animation())
            }

            HStack(spacing: SettingsView.iconSpacing) {
                RoleStatusIconView(memberStatus: .honorary)
                    .foregroundColor(.clubsColor)
                    .opacity(settings.showHonoraryMembers ? 1 : 0)
                    .accessibilityHidden(true)
                Toggle(String(localized: "Show honorary members",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Settings"),
                       isOn: $settings.showHonoraryMembers.animation())
            }

            HStack(spacing: SettingsView.iconSpacing) {
                RoleStatusIconView(memberStatus: .former)
                    .foregroundColor(.clubsColor)
                    .opacity(settings.showFormerMembers ? 1 : 0)
                    .accessibilityHidden(true)
                Toggle(String(localized: "Show former members",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Settings"),
                       isOn: $settings.showFormerMembers.animation())
            }

            // Deceased members are former members, so this row is hidden while former members are shown.
            if !settings.showFormerMembers {
                HStack(spacing: SettingsView.iconSpacing) {
                    RoleStatusIconView(memberStatus: .deceased)
                        .foregroundColor(.deceasedColor)
                        .opacity(settings.showDeceasedMembers ? 1 : 0)
                        .accessibilityHidden(true)
                    Toggle(String(localized: "Show deceased members",
                                  table: "PhotoClubHub.SwiftUI",
                                  comment: "Label of toggle in Settings"),
                           isOn: $settings.showDeceasedMembers.animation())
                }
            }

            HStack(spacing: SettingsView.iconSpacing) {
                RoleStatusIconView(memberStatus: .coach)
                    .foregroundColor(.clubsColor)
                    .opacity(settings.showExternalCoaches ? 1 : 0)
                    .accessibilityHidden(true)
                Toggle(String(localized: "Show external coaches",
                              table: "PhotoClubHub.SwiftUI",
                              comment: "Label of toggle in Settings"),
                       isOn: $settings.showExternalCoaches.animation())
            }

            SettingsViewThumbnail(settings: $settings, iconColor: .clubsColor)
        }) // end of section
    } // end of body

    /// A note below the section while every member category is off, so the empty Clubs tab doesn't come as a
    /// surprise. The Clubs tab says so too, but only once it is opened. `couldShowMembers` also decides
    /// `memberPredicate`, so the two can't disagree.
    @ViewBuilder
    private var emptyClubsFooter: some View {
        if settings.couldShowMembers == false {
            Text("Warning: Clubs will show no members when all member categories are off.",
                 tableName: "PhotoClubHub.SwiftUI",
                 comment: "In Settings, footer of the Club members section while every Show toggle there is off")
        }
    }
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
