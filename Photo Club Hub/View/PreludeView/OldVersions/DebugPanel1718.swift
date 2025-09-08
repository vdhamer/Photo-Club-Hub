//
//  DebugPanel1718.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/12/2022.
//

import SwiftUI

// Displays some numbers related to the Prelude screen graphics.
// The numbers update (via @Binding) when the screen is tapped.
@available(iOS, obsoleted: 19.0, message: "Please use 'DebugPanel2626' for versions above iOS 18.x")
struct DebugPanel1718: View {
    var size: CGSize
    @Binding var offset: OffsetVectorInCells1718
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

@available(iOS, obsoleted: 19.0, message: "Please use 'DebugPanel2626_Previews' for versions above iOS 18.x")
struct DebugPanel1718_Previews: PreviewProvider {
    @State fileprivate static var debugLocation = CGPoint(x: 0, y: 0)
    @State fileprivate static var logScale: Double = 32 // value driving the animation
    @State fileprivate static var offsetInCells = OffsetVectorInCells1718(x: 8, y: 6)

    static func intOffset(rect: CGSize, location: CGPoint) -> OffsetVectorInCells1718 {
        guard DebugPanel1718_Previews.logScale != 0 else { return OffsetVectorInCells1718(x: 0, y: 0) }
        let shortFrameDimension = min(rect.width, rect.height)
        let halfFrameDimension = shortFrameDimension / 2
        let cellPitchInPixels = shortFrameDimension/PreludeView1718.maxCellRepeat
        return OffsetVectorInCells1718(x: Int((((halfFrameDimension - location.x) / cellPitchInPixels)).rounded()),
                                       y: Int((((halfFrameDimension - location.y) / cellPitchInPixels)).rounded()))
    }

    static var previews: some View {
        GeometryReader {geo in
            HStack {
                DebugPanel1718(size: geo.size,
                                offset: DebugPanel1718_Previews.$offsetInCells,
                                location: DebugPanel1718_Previews.$debugLocation,
                                hidden: false)
            }
            .onTapGesture { location in
                debugLocation = location // for debugging only
                print(location)
                withAnimation(.easeInOut(duration: 7)) { // carefull: code is duplicated twice ;-(
                    if self.logScale == 0.0 { // if we are completely zoomed out at the time of the tap
                        self.logScale = log2(PreludeView1718.maxCellRepeat) // zoom in
                        offsetInCells = intOffset(rect: geo.size, location: location)
                    } else {
                        offsetInCells = OffsetVectorInCells1718(x: 0, y: 0)
                        self.logScale = 0.0 // zoom out
                    }
                }
            }
        }

    }
}
