//
//  DebugPanel2626.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/12/2022.
//

import SwiftUI

// Displays some numbers related to the Prelude screen graphics.
// The numbers update (via @Binding) when the screen is tapped.
@available(iOS 26.0, *)
struct DebugPanel2626: View {
    var size: CGSize
    @Binding var offset: OffsetVectorInCells2626
    @Binding var location: CGPoint
    var hidden: Bool

    var body: some View {
        if !hidden {
            VStack {
                // swiftlint:disable:next line_length
                Text("frameSize = [\(Int(size.width), format: IntegerFormatStyle.number.grouping(.never)),\(Int(size.height), format: IntegerFormatStyle.number.grouping(.never))]",
                     tableName: "PhotoClubHub.SwiftUI",
                     comment: "Used in DebugPanel. Can't avoid localization here. Just use original as translation")
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

@available(iOS 26.0, *)
struct DebugPanel2626_Previews: PreviewProvider {
    @State fileprivate static var debugLocation = CGPoint(x: 0, y: 0)
    @State fileprivate static var logScale: Double = 32 // value driving the animation
    @State fileprivate static var offsetInCells = OffsetVectorInCells2626(x: 8, y: 6)

    static func intOffset(rect: CGSize, location: CGPoint) -> OffsetVectorInCells2626 {
        guard DebugPanel2626_Previews.logScale != 0 else { return OffsetVectorInCells2626(x: 0, y: 0) }
        let shortFrameDimension = min(rect.width, rect.height)
        let halfFrameDimension = shortFrameDimension / 2
        let cellPitchInPixels = shortFrameDimension/PreludeView2626.Const.maxCellRepeat
        return OffsetVectorInCells2626(x: Int((((halfFrameDimension - location.x) / cellPitchInPixels)).rounded()),
                                       y: Int((((halfFrameDimension - location.y) / cellPitchInPixels)).rounded()))
    }

    static var previews: some View {
        GeometryReader {geo in
            HStack {
                DebugPanel2626(size: geo.size,
                               offset: DebugPanel2626_Previews.$offsetInCells,
                               location: DebugPanel2626_Previews.$debugLocation,
                               hidden: false)
            }
            .onTapGesture { location in
                debugLocation = location // for debugging only
                print(location)
                withAnimation(.easeInOut(duration: 7)) { // carefull: code is duplicated twice ;-(
                    if self.logScale == 0.0 { // if we are completely zoomed out at the time of the tap
                        self.logScale = log2(PreludeView2626.Const.maxCellRepeat) // zoom in
                        offsetInCells = intOffset(rect: geo.size, location: location)
                    } else {
                        offsetInCells = OffsetVectorInCells2626(x: 0, y: 0)
                        self.logScale = 0.0 // zoom out
                    }
                }
            }
        }

    }
}
