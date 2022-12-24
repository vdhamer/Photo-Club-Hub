//
//  PreludeView.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 05/03/2022.
//

import SwiftUI

struct PreludeView: View {

    // MARK: - Constants
    private static let maxCellRepeat: Double = 32 // max number of cells horizontally and vertically
    private static let log2CellRepeat: Double = log2(maxCellRepeat) // typically log2(32) = 5
    private static let squareSize = 5.5 / 18 // size of single colored square compared to pitch (0.3055555)
    private let crossHairsWidth: CGFloat = 1

    // MARK: - State variables
    @State private var offsetInCells = OffsetVectorInCells(x: 8, y: 6) // number of cell units left/above image center
    @State private var logScale = log2CellRepeat // value driving the animation
    @State private var willMoveToNextScreen = false // used to navigate to next screen
    @State private var debugPanelVisible = false // displays DebugPanel, can be toggled via keyboard "d" character
    @State private var debugLocation = CGPoint(x: 0, y: 0)
    @Environment(\.horizontalSizeClass) var horSizeClass

    func offset(frame rect: CGSize) -> CGSize { // used to position large image in the middle of a cell
        guard logScale != 0 else { return .zero }
        let shortFrameDimension: Double = min(rect.width, rect.height)
        let cellPitchInPixels: Double = shortFrameDimension/PreludeView.maxCellRepeat
        let offset = CGSize( width: cellPitchInPixels * Double(offsetInCells.x) * pow(2, logScale),
                             height: cellPitchInPixels * Double(offsetInCells.y) * pow(2, logScale) )
        return offset
    }

    func intOffset(rect: CGSize, location: CGPoint) -> OffsetVectorInCells { // used to translate tap to selected cell
        guard logScale != 0 else { return OffsetVectorInCells(x: 0, y: 0) }
        let shortFrameDimension = min(rect.width, rect.height)
        let halfFrameDimension = shortFrameDimension / 2
        let cellPitchInPixels = shortFrameDimension/PreludeView.maxCellRepeat
        return OffsetVectorInCells( x: Int((((halfFrameDimension - location.x) / cellPitchInPixels)).rounded()),
                                    y: Int((((halfFrameDimension - location.y) / cellPitchInPixels)).rounded()) )
    }

    var body: some View {
        NavigationStack { // defines navigation structure of entire app, even though you don't see navigation bar yet
            ZStack {
                AngularGradient(gradient: Gradient(colors: [.white, .fgwGreen,
                                                            .white, .fgwRed,
                                                            .white, .fgwGreen,
                                                            .white, .fgwBlue,
                                                            .white]
                ), center: .center)
                .saturation(0.5)
                .brightness(0.05)
                .ignoresSafeArea()
                .onTapGesture { // if user taps background, exit animation loop
                    withAnimation(.easeInOut(duration: 7)) {
                        willMoveToNextScreen = true
                    }
                }
                .navigate(to: MemberPortfoliosView().navigationBarTitle("Portfolios"),
                          when: $willMoveToNextScreen,
                          horSizeClass: horSizeClass)

                GeometryReader { geo in
                    ZStack(alignment: .center) {

                        ZStack {
                            Group {
                                LogoPath(logCellRepeat: PreludeView.log2CellRepeat, // upper left part of logo
                                         relPixelSize: PreludeView.squareSize,
                                         offsetPoint: .zero)
                                .fill(.fgwGreen)
                                .blendMode(.normal)
                                LogoPath(logCellRepeat: PreludeView.log2CellRepeat, // upper right part of logo
                                         relPixelSize: PreludeView.squareSize,
                                         offsetPoint: .top)
                                .fill(.fgwRed)
                                .blendMode(.normal)
                                LogoPath(logCellRepeat: PreludeView.log2CellRepeat, // lower left part of logo
                                         relPixelSize: PreludeView.squareSize,
                                         offsetPoint: .leading)
                                .fill(.fgwBlue)
                                .blendMode(.normal)
                                LogoPath(logCellRepeat: PreludeView.log2CellRepeat, // lower righ part of logo
                                         relPixelSize: PreludeView.squareSize,
                                         offsetPoint: .center)
                                .fill(.fgwGreen)
                                .blendMode(.normal)
                            }
                            .opacity(logScale == 0  ? 0.5 : 1)
                            Image("2021_FotogroepWaalre_058_square")
                                .resizable()
                                .scaledToFit()
                                .brightness(logScale == 0  ? 0.1 : 0.2)
                                .blendMode(.multiply)

                        }
                        .scaleEffect(CGSize(width: pow(2, logScale), height: pow(2, logScale))) // does the zooming
                        .offset(offset(frame: geo.size)) // does the panning
                        .frame(width: min(geo.size.width, geo.size.height),
                               height: min(geo.size.width, geo.size.height))
                        .overlay(RoundedRectangle(cornerRadius: CGFloat(Int(min(geo.size.width,
                                                                                geo.size.height) * 0.15)),
                                                  style: .continuous)
                        .stroke(.black, lineWidth: 2))
                        .clipShape(RoundedRectangle(cornerRadius: CGFloat(Int(min(geo.size.width,
                                                                                  geo.size.height) * 0.15)),
                                                    style: .continuous)) // approximate iOS app icon rounding
                        .contentShape(Rectangle())
                        .onTapGesture { location in
                            debugLocation = location
                            withAnimation(.easeInOut(duration: 7)) { // carefull: code is duplicated twice ;-(
                                if logScale == 0.0 { // if we are completely zoomed out at the time of the tap
                                    logScale = log2(PreludeView.maxCellRepeat) // zoom in
                                    offsetInCells = intOffset(rect: geo.size, location: location)
                                } else {
                                    offsetInCells = OffsetVectorInCells(x: 0, y: 0)
                                    logScale = 0.0 // zoom out
                                }
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    }

                    CrossHairs(isInvisible: true, circleScaling: 1.13)
                        .stroke(.purple, lineWidth: crossHairsWidth)
                        .blendMode(.normal)

                    EscapeHatch(willMoveToNextScreen: $willMoveToNextScreen,
                                offset: $offsetInCells,
                                location: $debugLocation,
                                size: geo.size,
                                debugPanelVisible: $debugPanelVisible)

                    Text(verbatim: "WAALRE")
                        .foregroundColor(.black)
                        .font(Font.custom("Gill Sans", size: 105*(min(geo.size.width, geo.size.height)/800)))
                        .kerning((140/3)*(min(geo.size.width, geo.size.height)/800))
                        .offset(x: (60/3)*(min(geo.size.width, geo.size.height)/800))
                        .opacity(logScale == 0  ? 0 : 1)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .onTapGesture { location in
                            debugLocation = location // for debugging only
                            print(location)
                            withAnimation(.easeInOut(duration: 7)) { // carefull: code is duplicated twice ;-(
                                if logScale == 0.0 { // if we are completely zoomed out at the time of the tap
                                    logScale = log2(PreludeView.maxCellRepeat) // zoom in
                                    offsetInCells = intOffset(rect: geo.size, location: location)
                                } else {
                                    offsetInCells = OffsetVectorInCells(x: 0, y: 0)
                                    logScale = 0.0 // zoom out
                                }
                            }
                        }
                        .dynamicTypeSize(DynamicTypeSize.large ...
                                         DynamicTypeSize.large) // don't let DynamicType change WAALRE size

                } // GeometryReader
                .drawingGroup()
                .padding()

            }
            .navigationBarTitle("Prelude")
        }
    }

    struct OffsetVectorInCells {
        // swiftlint:disable:next identifier_name
        var x, y: Int
    }

    struct LogoPath: Shape {
        var logCellRepeat: Double
        var relPixelSize: Double // value between 0.0 and 1.0
        var offsetPoint: UnitPoint

        var animatableData: Double {
            get {
                logCellRepeat
            }
            set {
                logCellRepeat = newValue
            }
        }

        func path(in rect: CGRect) -> Path {
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

    struct CrossHairs: Shape { // InsettableShape {
        let rotationAdjustment = Angle.degrees(90.0)
        let clockwise = true
        var isInvisible = false
        var circleScaling: Double = 1.0

        func path(in rect: CGRect) -> Path {
            guard !isInvisible else { return Path() } // nothing gets displayed

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

    struct EscapeHatch: View {
        let willMoveToNextScreen: Binding<Bool>
        let offset: Binding<OffsetVectorInCells>
        let location: Binding<CGPoint>
        var size: CGSize
        @Binding var debugPanelVisible: Bool

        var body: some View {
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    DebugPanel(size: size, offset: offset, location: location, hidden: !debugPanelVisible)
                    Spacer()
                    Button {
                        willMoveToNextScreen.wrappedValue = true
                    } label: {
                        Image(systemName: "arrowshape.turn.up.forward.circle")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                    }
                    .keyboardShortcut(.defaultAction) // return key

                    Button { // can't add multiple .keyboarShortcuts to same Button
                        willMoveToNextScreen.wrappedValue = true
                    } label: { EmptyView() }
                    .keyboardShortcut(" ", modifiers: []) // cannot support more than one shortcut

                    Button {
                        willMoveToNextScreen.wrappedValue = true
                    } label: { EmptyView() }
                    .keyboardShortcut(.cancelAction) // Esc key

                    Button {
                        debugPanelVisible.toggle()
                    } label: { EmptyView() }
                    .keyboardShortcut("d", modifiers: []) // cannot support more than one shortcut
                }
                .font(.title)
            }

        }
    }

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

}

struct AnimatedLogo_Previews: PreviewProvider {
    static var previews: some View {
        PreludeView()
            .previewInterfaceOrientation(.portrait)
    }
}
