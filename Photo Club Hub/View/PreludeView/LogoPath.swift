//
//  LogoPath.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/12/2022.
//

import SwiftUI

// Draw a 2-D array of red, green, blue, green squares.
// This is a spin-off of the logo of Fotogroep Waalre (Photo Club Waalre)
struct LogoPath: Shape {
    let logCellRepeat: Double
    let relPixelSize: Double // value between 0.0 and 1.0
    let offsetPoint: UnitPoint

    func path(in rect: CGRect) -> Path { // needed to conform to Shape protocol
        var path = Path()
        path.move(to: .zero)
        let frameSize: Double = min(rect.width, rect.height)
        let pixelPitch: Double = frameSize / pow(2, logCellRepeat)
        let pixelSize: Double = pixelPitch * relPixelSize
        let extraOffset: Double = (0.5 - relPixelSize)/2

        for row in 0..<Int(pow(2, logCellRepeat) + 0.1) { // + 0.1 to avoid rounding errors
            for column in 0..<Int(pow(2, logCellRepeat)+0.1) {
                let startX = pixelPitch * (Double(column) + offsetPoint.x + extraOffset)
                let startY = pixelPitch * (Double(row) + offsetPoint.y + extraOffset)
                let rect = CGRect(x: startX, y: startY, width: pixelSize, height: pixelSize)
                path.addRect(rect)
            }
        }
        return path
    }

}
