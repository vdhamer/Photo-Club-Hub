//
//  PreferencesViewThumbnail.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 28/04/2026.
//

import SwiftUI

struct PreferencesViewThumbnail: View {
    let localPreferences: Binding<PreferencesStruct>

    private var featuredBinding: Binding<Bool> {
        Binding<Bool>(
            get: { localPreferences.wrappedValue.preferenceForFeaturedImage },
            set: { localPreferences.wrappedValue.preferenceForFeaturedImage = $0 } // unused
        )
    }

    var body: some View {

        HStack {
            Image(systemName: "photo.artframe")
                .foregroundStyle(.gray, .memberPortfolioColor, .red)
            Picker(String(localized: "ThumbnailMembers",
                          table: "PhotoClubHub.SwiftUI",
                          comment: "Picker to display featuredImage or photographerImage"),
                   selection: featuredBinding) {
                Text(String(localized: "featuredImage",
                            table: "PhotoClubHub.SwiftUI",
                            comment: "Label of picker item")).tag(true)
                Text(String(localized: "photographerImage",
                            table: "PhotoClubHub.SwiftUI",
                            comment: "Label of picker item")).tag(false)
            }
        }
    }
}

// Believe it or not, the following Preview actually works
#Preview("PreferencesViewThumbnail", traits: .portrait) {
    struct Container: View {
        @State private var prefs = PreferencesStruct.defaultValue
        var body: some View {
            PreferencesViewThumbnail(localPreferences: $prefs)
                .padding()
        }
    }
    return Container()
}
