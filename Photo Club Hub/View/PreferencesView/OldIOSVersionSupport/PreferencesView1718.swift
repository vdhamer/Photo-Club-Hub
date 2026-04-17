//
//  PreferencesView1718.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 11/12/2021.
//

import SwiftUI

@available(iOS, obsoleted: 19.0, message: "Please use 'PreferencesView2626' for versions above iOS 18.x")
@MainActor
struct PreferencesView1718: View {

    @Binding var preferences: PreferencesStruct // parameters for various Toggles and Pickers
    @State var localPreferences: PreferencesStruct // in case the view gets a Cancel option

    init(preferences: Binding<PreferencesStruct>) {
        _preferences = preferences
        localPreferences = preferences.wrappedValue
    }

    var body: some View {
        PreferencesView(preferences: $preferences)
    }

}

// believe it or not, the following Preview does work
@available(iOS, obsoleted: 19.0, message: "Please use 'PreferencesView2626_Previews' for versions above iOS 18.x")
struct PreferencesView1718_Previews: PreviewProvider {
    @State static private var title = "PreferencesView Preview"
    @State static var preferences = PreferencesStruct.defaultValue

    static var previews: some View {
        PreferencesView1718(preferences: $preferences)
            .navigationTitle(title)
    }
}
