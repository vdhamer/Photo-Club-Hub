//
//  Crosshairs2626.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/12/2022.
//

import SwiftUI

// Draws 8 lines through the middle of the screen
// with a circle around the central point, aka cell (0,0).
// This was used to tune the Prelude screen graphics.
@available(iOS, obsoleted: 19.0, message: "Please use 'DebugPanel2626_Previews' for versions above iOS 18.x")
struct CrossHairs1718: Shape {

    let hidden: Bool // provided when instantiating CrossHairs
    let circleScaling: Double

    let rotationAdjustment = Angle.degrees(90.0)
    let clockwise = true

    init(hidden: Bool, circleScaling: Double = 1.13) {
        self.hidden = hidden
        self.circleScaling = circleScaling
    }

    func path(in rect: CGRect) -> Path {
        guard !hidden else { return Path() } // nothing gets displayed

        var path = Path()
        for startAngle in stride(from: 0.0, through: 315.0, by: 45.0) {
            path.move(to: CGPoint(x: rect.midX, y: rect.midY))
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), // 45 degree pie segment
                        radius: rect.midX * circleScaling,
                        startAngle: Angle.degrees(startAngle)-rotationAdjustment,
                        endAngle: Angle.degrees(startAngle+45)-rotationAdjustment,
                        clockwise: !clockwise)
            path.addLine(to: CGPoint(x: rect.midX, y: rect.midY)) // center
            path.closeSubpath()
        }
        return path
    }
}

@available(iOS, obsoleted: 19.0, message: "Please use 'DebugPanel2626_Previews' for versions above iOS 18.x")
struct Crosshairs1718_Previews: PreviewProvider {
    static let crossHairsWidth: CGFloat = 2
    static let crossHairsColor: Color = Color(UIColor(white: 0.5, alpha: 0.5))

    static var previews: some View {
        CrossHairs1718(hidden: false, circleScaling: 0.5)
            .stroke(crossHairsColor, lineWidth: crossHairsWidth)
            .blendMode(.normal)
    }
}
