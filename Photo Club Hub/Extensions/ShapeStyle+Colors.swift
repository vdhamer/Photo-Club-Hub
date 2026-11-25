//
//  ShapeStyle+Colors.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 05/02/2022.
//

import SwiftUI // for ShapeStyle

extension ShapeStyle where Self == Color {

    static var clubsColor: Color {
        Color("_ClubsColor") // from asset catalog
    }

    static var peopleColor: Color {
        Color("_PeopleColor") // from asset catalog
    }

    static var mapsColor: Color {
        Color("_OrganizationColor") // from asset catalog
    }

    /// A club or museum on a map that is not the map's own organization, highlighted or a ghost (`markerTint`).
    /// Also the icons of "Show clubs" and "Show museums" in the Settings tab.
    static var plainMarkerColor: Color {
        .blue // system blue, not from the asset catalog
    }

    /// A ghost on a map: an inactive or possibly inactive organization that is not the map's own (`markerTint`).
    /// Also the icon of "Show inactive organizations" in the Settings tab, and an inactive club's Clubs tab header.
    static var ghostMarkerColor: Color {
        .gray // system gray, not from the asset catalog
    }

    static var settingsColor: Color {
        Color("_SettingsColor") // from asset catalog (sepia brown; lighter tan in dark mode)
    }

    static var deceasedColor: Color {
        Color("_DeceasedColor") // from asset catalog
    }

    static var linkColor: Color {
        Color("_LinkColor") // from asset catalog (this color differs in dark and in light mode)
    }

    static var fgwRed: Color {
        Color("_FGWRed") // from asset catalog (used in AnimatedLogo of Fotogroep Waalre)
    }

    static var fgwGreen: Color {
        Color("_FGWGreen") // from asset catalog (used in AnimatedLogo of Fotogroep Waalre)
    }

    static var fgwBlue: Color {
        Color("_FGWBlue") // from asset catalog (used in AnimatedLogo of Fotogroep Waalre)
    }

    static var sliderColor: Color {
        Color("_SliderColor") // from asset catalog
    }

    static var plannedColor: Color {
        Color("_PlannedColor") // from asset catalog
    }

    static var unplannedColor: Color {
        Color("_UnplannedColor") // from asset catalog
    }
}
