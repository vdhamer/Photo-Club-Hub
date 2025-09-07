//
//  PreferencesView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 11/12/2021.
//

import SwiftUI

let valueOverwrittenByInit = false // dummy constant

@MainActor
struct PreferencesView: View {

    @Binding var preferences: PreferencesStruct
    @Environment(\.dismiss) var dismiss: DismissAction // \.dismiss requires iOS 15

    @State fileprivate var localPreferences = PreferencesStruct.defaultValue // parameters for various Toggles()

    fileprivate let title = String(localized: "Preferences",
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
                                         comment: "In Preferences, above toggles like \"Show former members\""),
                            content: {
                        HStack {
                            RoleStatusIconView(memberStatus: .current)
                                .foregroundColor(.memberPortfolioColor)
                            Toggle(String(localized: "Show current members",
                                          comment: "Label of toggle in Preferences"),
                                   isOn: $localPreferences.showCurrentMembers.animation())
                        }
                        if localPreferences.showCurrentMembers == false {
                            HStack {
                                RoleStatusIconView(memberRole: .viceChairman)
                                    .foregroundColor(.deceasedColor)
                                Toggle(String(localized: "Show club officers",
                                              comment: "Label of toggle in Preferences"),
                                       isOn: $localPreferences.showOfficers)
                            }
                        } else {
                            HStack {
                                RoleStatusIconView(memberRole: .viceChairman)
                                    .foregroundColor(.deceasedColor)
                                Text("“Current members” includes “club officers”",
                                     comment: "Shown when \"Show club officers\" entry is missing in Preferences")
                                    .foregroundColor(.gray)
                            }
                        }
                        HStack {
                            RoleStatusIconView(memberStatus: .prospective)
                                .foregroundColor(.memberPortfolioColor)
                            Toggle(String(localized: "Show aspiring members",
                                          comment: "Label of toggle in Preferences"),
                                   isOn: $localPreferences.showAspiringMembers)
                        }
                        HStack {
                            RoleStatusIconView(memberStatus: .honorary)
                                .foregroundColor(.memberPortfolioColor)
                            Toggle(String(localized: "Show honorary members",
                                          comment: "Label of toggle in Preferences"),
                                   isOn: $localPreferences.showHonoraryMembers)
                        }
                        HStack {
                            RoleStatusIconView(memberStatus: .former)
                                .foregroundColor(.memberPortfolioColor)
                            Toggle(String(localized: "Show former members", comment: "Label of toggle in Preferences"),
                                   isOn: $localPreferences.showFormerMembers.animation())
                        }
                        if localPreferences.showFormerMembers == false {
                            HStack { // moving this outside the if() works but gives a boring animation
                                RoleStatusIconView(memberStatus: .deceased)
                                    .foregroundColor(.deceasedColor)
                                Toggle(String(localized: "Show deceased members",
                                              comment: "Label of toggle in Preferences"),
                                       isOn: $localPreferences.showDeceasedMembers)
                            }
                        } else {
                            HStack {
                                RoleStatusIconView(memberStatus: .deceased)
                                    .foregroundColor(.deceasedColor)
                                Text(
                                    "“Former members” includes “deceased members”",
                                    comment: "Shown when \"Show deceased members\" entry is missing in Preferences")
                                    .foregroundColor(.gray)
                            }
                        }
                        HStack {
                            RoleStatusIconView(memberStatus: .coach)
                                .foregroundColor(.memberPortfolioColor)
                            Toggle(String(localized: "Show external coaches",
                                          comment: "Label of toggle in Preferences"),
                                   isOn: $localPreferences.showExternalCoaches)
                        }
                    }) // Section

                    Section(header: Text("Advanced",
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
            .apply {
                if #available(iOS 18.0, *) {
                    $0.presentationSizing(.form)
                } else {
                    $0
                }
            }
        })
    }

}

struct PreferencesView_Previews: PreviewProvider {
    @State static fileprivate var title = "PreferencesView Preview"
    @State static var preferences = PreferencesStruct.defaultValue

    static var previews: some View {
        PreferencesView(preferences: $preferences)
            .navigationTitle(title)
    }
}
