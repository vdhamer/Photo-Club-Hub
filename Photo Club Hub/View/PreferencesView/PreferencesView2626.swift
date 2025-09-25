//
//  PreferencesView2626.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 11/12/2021.
//

import SwiftUI

@available(iOS 26.0, *)
@MainActor
struct PreferencesView2626: View {

    @Binding var preferences: PreferencesStruct
    @Environment(\.dismiss) var dismiss: DismissAction // \.dismiss requires iOS 15

    @State fileprivate var localPreferences = PreferencesStruct.defaultValue // parameters for various Toggles()

    fileprivate let title = String(localized: "Preferences",
                                   table: "PhotoClubHub.SwiftUI",
                                   comment: "Title of screen with toggles to adjust preferences")
    fileprivate static let animation: Animation = Animation.easeIn(duration: 5)

    init(preferences: Binding<PreferencesStruct>) {
        _preferences = preferences

        // https://stackoverflow.com/questions/57060854/how-keep-a-copy-of-original-binding-value
        _localPreferences = State(initialValue: preferences.wrappedValue)
    }

    var body: some View {
        GeometryReader(content: { _ in
            NavigationStack {
                List {
                    Section(header: Text("Member categories",
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
                    }) // Section

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

                } // List
                .navigationTitle(title)
            }
            .onDisappear {
                // need to update Bindings for showPhotoClubsList etc
                preferences = localPreferences
            }
            .presentationSizing(.form)
        })
    }

}

@available(iOS 26.0, *)
struct PreferencesView2626_Previews: PreviewProvider {
    @State static fileprivate var title = "PreferencesView Preview"
    @State static var preferences = PreferencesStruct.defaultValue

    static var previews: some View {
        PreferencesView2626(preferences: $preferences)
            .navigationTitle(title)
    }
}
