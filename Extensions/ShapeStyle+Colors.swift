//
//  ShapeStyle+Colors.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 05/02/2022.
//

import SwiftUI // for ShapeStyle

extension ShapeStyle where Self == Color {

    static var memberPortfolioColor: Color {
        Color("_MemberPortfolioColor") // from asset catalog
    }

    static var photographerColor: Color {
        Color("_PhotographerColor") // from asset catalog
    }

    static var photoClubColor: Color {
        Color("_PhotoClubColor") // from asset catalog
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
