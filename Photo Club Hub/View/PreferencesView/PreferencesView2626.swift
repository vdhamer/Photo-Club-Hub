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

    @Binding var preferences: PreferencesStruct // parameters for various Toggles and Pickers
    @State var localPreferences: PreferencesStruct // in case the view gets a Cancel option

    init(preferences: Binding<PreferencesStruct>) {
        _preferences = preferences
        localPreferences = preferences.wrappedValue
    }

    var body: some View {
        PreferencesView(preferences: $preferences)
            .presentationSizing(.page) // works on starting iOS 26+ only
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
