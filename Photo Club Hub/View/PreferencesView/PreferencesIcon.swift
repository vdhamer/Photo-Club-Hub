//
//  PreferencesIcon.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 10/01/2026.
//

import SwiftUI

struct PreferencesIcon: View {
    @Environment(\.isEnabled) private var isEnabled: Bool // I forgot what this was meant for

    var body: some View {
        Image("slider.horizontal.3.rectangle")
            .font(.title)
            .foregroundStyle(isEnabled ? .memberPortfolioColor : .gray, // isEnabled is always true :-(
                             .gray,
                             isEnabled ? .sliderColor : .gray)
    }
}

// Believe it or not, the following Preview actually works
#Preview("PreferencesIcon", traits: .portrait) {
    VStack(spacing: 16) {
        // Enabled state (default)
        PreferencesIcon()
            .environment(\.isEnabled, true)
        // Disabled state to visualize styling when not enabled
        PreferencesIcon()
            .environment(\.isEnabled, false)
    }
    .padding()
    .preferredColorScheme(.light)
}
