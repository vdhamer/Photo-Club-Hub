//
//  SettingsView.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 11/12/2021.
//

import SwiftUI

let valueOverwrittenByInit = false // dummy constant

struct SettingsView: View {

    @Binding var settings: SettingsStruct
    @Environment(\.dismiss) var dismiss: DismissAction // \.dismiss requires iOS 15

    @State private var localSettings = SettingsStruct.defaultValue // parameters for various Toggles()

    private let title = String(localized: "Preferences", comment: "Title of screen with toggles to adjust preferences")
    private static let animation: Animation = Animation.easeIn(duration: 5)

    init(settings: Binding<SettingsStruct>) {
        _settings = settings

        // https://stackoverflow.com/questions/57060854/how-keep-a-copy-of-original-binding-value
        _localSettings = State(initialValue: settings.wrappedValue)
    }

    var body: some View {
        GeometryReader(content: { geo in
            NavigationView {
                List {
                    Section(header: Text("Member categories",
                                         comment: "In Settings, above toggles like 'Show former members'"),
                            content: {
                        HStack {
                            RoleStatusIconView(memberStatus: .current)
                                .foregroundColor(.memberColor)
                            Toggle(String(localized: "Show current members",
                                          comment: "Label of toggle in Settings"),
                                   isOn: $localSettings.showCurrentMembers.animation())
                        }
                        if localSettings.showCurrentMembers == false {
                            HStack {
                                RoleStatusIconView(memberRole: .viceChairman)
                                    .foregroundColor(.deceasedColor)
                                    Toggle(String(localized: "Show club officers",
                                                  comment: "Label of toggle in Settings"),
                                           isOn: $localSettings.showOfficers)
                            }
                        } else {
                            HStack {
                                RoleStatusIconView(memberRole: .viceChairman)
                                    .foregroundColor(.deceasedColor)
                                Text("'Current members' includes 'club officers'",
                                     comment: "Shown when 'Show club officers' entry is missing in Settings")
                                    .foregroundColor(.gray)
                            }
                        }
                        HStack {
                            RoleStatusIconView(memberStatus: .prospective)
                                .foregroundColor(.memberColor)
                            Toggle(String(localized: "Show aspiring members", comment: "Label of toggle in Settings"),
                                   isOn: $localSettings.showAspiringMembers)
                        }
                        HStack {
                            RoleStatusIconView(memberStatus: .honorary)
                                .foregroundColor(.memberColor)
                            Toggle(String(localized: "Show honorary members", comment: "Label of toggle in Settings"),
                                   isOn: $localSettings.showHonoraryMembers)
                        }
                        HStack {
                            RoleStatusIconView(memberStatus: .former)
                                .foregroundColor(.memberColor)
                            Toggle(String(localized: "Show former members", comment: "Label of toggle in Settings"),
                                   isOn: $localSettings.showFormerMembers.animation())
                        }
                        if localSettings.showFormerMembers == false {
                            HStack { // moving this outside the if() works but gives a boring animation
                                RoleStatusIconView(memberStatus: .deceased)
                                    .foregroundColor(.deceasedColor)
                                Toggle(String(localized: "Show deceased members",
                                              comment: "Label of toggle in Settings"),
                                       isOn: $localSettings.showDeceasedMembers)
                            }
                        } else {
                            HStack {
                                RoleStatusIconView(memberStatus: .deceased)
                                    .foregroundColor(.deceasedColor)
                                Text(
                                    "'Former members' includes 'deceased members'",
                                    comment: "Shown when 'Show deceased members' entry is missing in Settings")
                                    .foregroundColor(.gray)
                            }
                        }
                        HStack {
                            RoleStatusIconView(memberStatus: .coach)
                                .foregroundColor(.memberColor)
                            Toggle(String(localized: "Show external coaches", comment: "Label of toggle in Settings"),
                                   isOn: $localSettings.showExternalCoaches)
                        }
                    })
                }
                .navigationTitle(title)
                .toolbar {
                    ToolbarItemGroup(placement: ToolbarItemPlacement.confirmationAction) {
                        Button { // actual saving done in .onDisappear
                            dismiss()
                        } label: {
                            Text("Done",
                                 comment: "Button at top right of Settings. Stores preference settings.")
                        }
                        .disabled(localSettings.nothingEnabled)
                    }
                }
            }
            .onDisappear {
                // need to update Bindings for showPhotoClubsList etc
                settings = localSettings
            }
            .frame(minWidth: geo.size.width*0.2, idealWidth: geo.size.width*0.35, maxWidth: geo.size.width,
                   minHeight: geo.size.height*0.3, idealHeight: geo.size.height*0.8, maxHeight: geo.size.height)
        })
    }

}

struct SettingsView_Previews: PreviewProvider {
    @State static private var title = "FilterSettings Preview"
    @State static var settings = SettingsStruct.defaultValue

    static var previews: some View {
        SettingsView(settings: $settings)
            .navigationTitle(title)
            .navigationViewStyle(.stack)
    }
}
