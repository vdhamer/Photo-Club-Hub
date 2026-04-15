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
    @State var localPreferences: PreferencesStruct // in case the view gets a Cancel option

    init(preferences: Binding<PreferencesStruct>) {
        _preferences = preferences
        localPreferences = preferences.wrappedValue
    }

    var body: some View {
        PreferencesViewBody(preferences: $preferences)
            .presentationSizing(.page) // iOS 26+
            .onDisappear {
                // need to update Bindings for showPhotoClubsList etc
                preferences = localPreferences
            }
    }

}

// believe it or not, the following Preview does work
@available(iOS 26.0, *)
struct PreferencesView2626_Previews: PreviewProvider {
    @State static private var title = "PreferencesView Preview"
    @State static var preferences = PreferencesStruct.defaultValue

    static var previews: some View {
        PreferencesView2626(preferences: $preferences)
            .navigationTitle(title)
    }

}
