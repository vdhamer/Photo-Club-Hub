//
//  DebugPanel.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 24/12/2022.
//

import SwiftUI

// Displays some numbers related to the Prelude screen graphics.
// The numbers update (via @Binding) when the screen is tapped.
struct DebugPanel: View {
    var size: CGSize
    @Binding var offset: OffsetVectorInCells
    @Binding var location: CGPoint
    var hidden: Bool

    var body: some View {
        if !hidden {
            VStack {
                // swiftlint:disable:next line_length
                Text("frameSize = [\(Int(size.width), format: IntegerFormatStyle.number.grouping(.never)),\(Int(size.height), format: IntegerFormatStyle.number.grouping(.never))]",
                comment: "Used in DebugPanel. I couldn't avoid localization here. Just use original as translation")
                // I didn't manage to avoid localization in the above Text.
                Text(verbatim: "tapLocation = [\(Int(location.x)), \(Int(location.y))]")
                Text(verbatim: "offsetInCells = [\(offset.x), \(offset.y)]")
            }
            .font(.body)
            .foregroundColor(.black)
            .padding()
            .border(.black)
            .background { Color(white: 0.9) }
            .transaction { transaction in // https://www.avanderlee.com/swiftui/disable-animations-transactions/
                transaction.animation = nil
            }
        }
    }
}

struct DebugPanel_Previews: PreviewProvider {
    @State private static var debugLocation = CGPoint(x: 0, y: 0)
    @State private static var logScale: Double = 32 // value driving the animation
    @State private static var offsetInCells = OffsetVectorInCells(x: 8, y: 6)

    static func intOffset(rect: CGSize, location: CGPoint) -> OffsetVectorInCells {
        guard DebugPanel_Previews.logScale != 0 else { return OffsetVectorInCells(x: 0, y: 0) }
        let shortFrameDimension = min(rect.width, rect.height)
        let halfFrameDimension = shortFrameDimension / 2
        let cellPitchInPixels = shortFrameDimension/PreludeView.maxCellRepeat
        return OffsetVectorInCells( x: Int((((halfFrameDimension - location.x) / cellPitchInPixels)).rounded()),
                                    y: Int((((halfFrameDimension - location.y) / cellPitchInPixels)).rounded()) )
    }

    static var previews: some View {
        GeometryReader {geo in
            HStack {
                DebugPanel(size: geo.size,
                           offset: DebugPanel_Previews.$offsetInCells,
                           location: DebugPanel_Previews.$debugLocation,
                           hidden: false)
            }
            .onTapGesture { location in
                debugLocation = location // for debugging only
                print(location)
                withAnimation(.easeInOut(duration: 7)) { // carefull: code is duplicated twice ;-(
                    if self.logScale == 0.0 { // if we are completely zoomed out at the time of the tap
                        self.logScale = log2(PreludeView.maxCellRepeat) // zoom in
                        offsetInCells = intOffset(rect: geo.size, location: location)
                    } else {
                        offsetInCells = OffsetVectorInCells(x: 0, y: 0)
                        self.logScale = 0.0 // zoom out
                    }
                }
            }
        }

    }
}
