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
    @State private var localPreferences = PreferencesStruct.defaultValue // parameters for various Toggles() TODO remove

    private static let animation: Animation = Animation.easeIn(duration: 5) // TODO used?

    init(preferences: Binding<PreferencesStruct>) {
        _preferences = preferences

        // https://stackoverflow.com/questions/57060854/how-keep-a-copy-of-original-binding-value
        _localPreferences = State(initialValue: preferences.wrappedValue)
    }

    var body: some View {

        PreferencesViewBody(preferences: $preferences)
            .presentationSizing(.page) // iOS 26+       
    }

}

// believe it or not, the following Preview actually works
@available(iOS 26.0, *)
struct PreferencesView2626_Previews: PreviewProvider {
    @State static private var title = "PreferencesView Preview"
    @State static var preferences = PreferencesStruct.defaultValue

    static var previews: some View {
        PreferencesView2626(preferences: $preferences)
            .navigationTitle(title)
    }

}
