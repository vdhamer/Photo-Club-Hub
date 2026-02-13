//
//  SemanticColor+ExtraColors.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 12/02/2026.
//

import SemanticColorPicker // for SemanticColor
import Foundation // for UUID
import SwiftUI // for Color

extension SemanticColor {

    struct ExtraColor: Identifiable, ColorConvertible {
        let id: UUID = UUID()
        let color: Color
        let description: String
    }

    var extraColors: [ExtraColor] { // computed property because extension cannot contain stored properties
        return [
            .init(color: .gray, description: "Gray")
        ]
    }

}
