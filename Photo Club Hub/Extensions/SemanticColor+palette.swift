//
//  SemanticColor+palette.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 22/02/2026.
//

import SemanticColorPicker // for SemanticColor
import SwiftUI // for Color

extension SemanticColor {

    static let transparent = SemanticColor(id: "transparent",
                                           description: "transparent color",
                                           color: Color(UIColor(white: 0.5, alpha: 0.5)))

    public static let palette: [SemanticColor] = [
        .red, .orange, .yellow, .green, .mint, .teal,
        .cyan, .blue, .indigo, .purple, .pink, .brown
    ]

}
