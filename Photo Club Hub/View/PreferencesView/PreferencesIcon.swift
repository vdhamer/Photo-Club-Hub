//
//  PreferencesIcon.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 10/01/2026.
//

import SwiftUI

struct PreferencesIcon: View {
    @Environment(\.isEnabled) private var isEnabled: Bool // I forgot what was meant for

    var body: some View {
        Image("slider.horizontal.3.rectangle")
            .font(.title)
            .foregroundStyle(isEnabled ? .memberPortfolioColor : .gray, // isEnabled is always true :-(
                             .gray,
                             isEnabled ? .sliderColor : .gray)
    }
}
