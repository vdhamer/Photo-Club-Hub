//
//  AnimatedLogo.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 05/03/2022.
//

import SwiftUI

struct AnimatedLogo: View {

    // MARK: - Constants
    private static let maxCellRepeat: Double = 32 // max number of cells horizontally and vertically
    private static let log2CellRepeat: Double = log2(maxCellRepeat) // typically log2(32) = 5
    private static let squareSize = 5.5 / 18 // size of single colored square compared to pitch (0.3055555)
    private let crossHairsWidth: CGFloat = 1
    // private static let maxTapCounter = 8

    // MARK: - State variables
    @State private var offsetInCells = OffsetVectorInCells(x: 8, y: 6) // number of cell units left/above image center
    @State private var logScale = log2CellRepeat // value driving the animation
    @State private var willMoveToNextScreen = false // used to navigate to next screen
    @State private var tapCounter: Int = 0

    private var fullOwnerName: String // irrelevant here; just passed through to main View (eliminate via environment?)
    init(fullOwnerName: String = "Peter van den Hamer") {
        self.fullOwnerName = fullOwnerName
    }

    func offset(frame rect: CGSize) -> CGSize { // used to position large image in the middle of a cell
        guard logScale != 0 else { return .zero }
        let shortFrameDimension: Double = min(rect.width, rect.height)
        let cellPitchInPixels: Double = shortFrameDimension/AnimatedLogo.maxCellRepeat
        let offset = CGSize( width: cellPitchInPixels * Double(offsetInCells.x) * pow(2, logScale),
                             height: cellPitchInPixels * Double(offsetInCells.y) * pow(2, logScale) )
        return offset
    }

    func intOffset(rect: CGSize, location: CGPoint) -> OffsetVectorInCells { // used to translate tap to selected cell
        guard logScale != 0 else { return OffsetVectorInCells(x: 0, y: 0) }
        let shortFrameDimension = min(rect.width, rect.height)
        let halfFrameDimension = shortFrameDimension / 2
        let cellPitchInPixels = shortFrameDimension/AnimatedLogo.maxCellRepeat
        return OffsetVectorInCells( x: Int((((halfFrameDimension - location.x) / cellPitchInPixels)).rounded()),
                                    y: Int((((halfFrameDimension - location.y) / cellPitchInPixels)).rounded()) )
    }

    var body: some View {
        ZStack { // not needed if there is no slider
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
            GeometryReader { geo in
                ZStack(alignment: .center) {

                    ZStack {
                        Group {
                            LogoPath(logCellRepeat: AnimatedLogo.log2CellRepeat, // upper left part of logo
                                     relPixelSize: AnimatedLogo.squareSize,
                                     offsetPoint: .zero)
                                .fill(.fgwGreen)
                                .blendMode(.normal)
                            LogoPath(logCellRepeat: AnimatedLogo.log2CellRepeat, // upper right part of logo
                                     relPixelSize: AnimatedLogo.squareSize,
                                     offsetPoint: .top)
                                .fill(.fgwRed)
                                .blendMode(.normal)
                            LogoPath(logCellRepeat: AnimatedLogo.log2CellRepeat, // lower left part of logo
                                     relPixelSize: AnimatedLogo.squareSize,
                                     offsetPoint: .leading)
                                .fill(.fgwBlue)
                                .blendMode(.normal)
                            LogoPath(logCellRepeat: AnimatedLogo.log2CellRepeat, // lower righ part of logo
                                     relPixelSize: AnimatedLogo.squareSize,
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

                    .frame(width: min(geo.size.width, geo.size.height), height: min(geo.size.width, geo.size.height))
                    .overlay(RoundedRectangle(cornerRadius: CGFloat(Int(min(geo.size.width,
                                                                            geo.size.height) * 0.15)),
                                              style: .continuous)
                                .stroke(.black, lineWidth: 2))
                    .clipShape(RoundedRectangle(cornerRadius: CGFloat(Int(min(geo.size.width,
                                                                  geo.size.height) * 0.15)),
                                                style: .continuous)) // approximate iOS rounding
                    .contentShape(Rectangle())
                    .onTapGesture { location in
                        withAnimation(.easeInOut(duration: 7)) { // carefull: code is duplicated twice ;-(
                            // tapCounter = min(AnimatedLogo.maxTapCounter, tapCounter+1)
                            if logScale == 0.0 { // if we are completely zoomed out at the time of the tap
                                logScale = log2(AnimatedLogo.maxCellRepeat) // zoom in
                                offsetInCells = intOffset(rect: geo.size, location: location)
                            } else {
                                offsetInCells = OffsetVectorInCells(x: 0, y: 0)
                                logScale = 0.0 // zoom out
                            }
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }

                CrossHairs(isVisible: false, circleScaling: 1.13)
                    .stroke(.purple, lineWidth: crossHairsWidth)
                    .blendMode(.normal)

                EscapeHatch(tapCounter: tapCounter, willMoveToNextScreen: $willMoveToNextScreen)

                Text(verbatim: "WAALRE")
                    .foregroundColor(.black)
                    .font(Font.custom("Gill Sans", size: 105*(min(geo.size.width, geo.size.height)/800)))
                    .kerning((140/3)*(min(geo.size.width, geo.size.height)/800))
                    .offset(x: (60/3)*(min(geo.size.width, geo.size.height)/800))
                    .opacity(logScale == 0  ? 0 : 1)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .onTapGesture { location in
                        withAnimation(.easeInOut(duration: 7)) { // carefull: code is duplicated twice ;-(
                            // tapCounter = min(AnimatedLogo.maxTapCounter, tapCounter+1)
                            if logScale == 0.0 { // if we are completely zoomed out at the time of the tap
                                logScale = log2(AnimatedLogo.maxCellRepeat) // zoom in
                                offsetInCells = intOffset(rect: geo.size, location: location)
                            } else {
                                offsetInCells = OffsetVectorInCells(x: 0, y: 0)
                                logScale = 0.0 // zoom out
                            }
                        }
                    }
                    .dynamicTypeSize(DynamicTypeSize.large ...
                                     DynamicTypeSize.large) // don't let DynamicType change WAALRE size
            }
                .drawingGroup()
                .padding()

        }
            .navigate(to: MemberListView(), when: $willMoveToNextScreen)
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
        var isVisible = true
        var circleScaling: Double = 1.0

        func path(in rect: CGRect) -> Path {
            var path = Path()
            if isVisible {
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
            }
            return path
        }
    }

    struct EscapeHatch: View {
        let tapCounter: Int
        let willMoveToNextScreen: Binding<Bool>

        var body: some View {
            VStack {
                Spacer()
                HStack {
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
                }
                // .opacity(Double(tapCounter)/Double(AnimatedLogo.maxTapCounter))
                .font(.title)
            }

        }
    }

}

struct AnimatedLogo_Previews: PreviewProvider {

    static var previews: some View {
        AnimatedLogo()
            .previewInterfaceOrientation(.portrait)
    }
}
