//
//  HighlightIconColorTest.swift
//  Photo Club HubTests
//
//  Created by Claude Code (guided by Peter van den Hamer) on 24/11/2026.
//

import Testing
import SwiftUI              // for Color
import SemanticColorPicker  // for SemanticColor
import Photo_Club_Hub_Data  // for OrganizationTypeEnum
@testable import Photo_Club_Hub

// The Fotobond highlighting rows in the Settings tab show a club marker: in the highlighting color while highlighting
// is on, in plain blue while it is off (#892). That icon picks its color itself rather than through the maps' rule
// (`markerTint`), so these tests check that the two agree, for every color the picker offers.
@Suite("The Settings tab's highlighting icon matches the maps")
@MainActor
struct HighlightIconColorTests {

    /// The default settings with `color` as highlighting color, highlighting Fotobond clubs, the other clubs, or none.
    private func settings(color: SemanticColor, highlightFotobond: Bool?) -> SettingsStruct {
        var settings = SettingsStruct.defaultValue
        settings.highlightColor = color
        settings.highlightFotobondNL = highlightFotobond == true
        settings.highlightNonFotobondNL = highlightFotobond == false
        return settings
    }

    /// The tint the maps give a club that is not the map's own and not a ghost.
    private func mapTint(isInFotobond: Bool, settings: SettingsStruct) -> Color {
        markerTint(organizationType: .club, isOwn: false, isInFotobond: isInFotobond, isGhost: false,
                   settings: settings)
    }

    @Test("The icon has the color of a highlighted club on the map",
          arguments: SemanticColor.palette, [true, false])
    func iconMatchesHighlightedClub(color: SemanticColor, highlightFotobond: Bool) {
        let settings = settings(color: color, highlightFotobond: highlightFotobond)
        // the highlighted clubs are the Fotobond clubs, or the others
        let highlightedClubTint = mapTint(isInFotobond: highlightFotobond, settings: settings)
        #expect(SettingsViewOrganizationsSection.highlightIconColor(for: settings) == highlightedClubTint)
    }

    // With highlighting off the maps draw every club in plain blue, whatever the chosen color, and so does the icon.
    @Test("With highlighting off, the icon has the plain color of every club", arguments: SemanticColor.palette)
    func iconIsPlainWhenOff(color: SemanticColor) {
        let settings = settings(color: color, highlightFotobond: nil)
        #expect(SettingsViewOrganizationsSection.highlightIconColor(for: settings) == .plainMarkerColor)
        #expect(mapTint(isInFotobond: true, settings: settings) == .plainMarkerColor)
        #expect(mapTint(isInFotobond: false, settings: settings) == .plainMarkerColor)
    }

}
