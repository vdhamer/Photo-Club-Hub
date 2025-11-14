//
//  PreludeView2626.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 05/03/2022.
//

import SwiftUI

@available(iOS 26.0, *)
struct PreludeView2626: View {

    // MARK: - Constants
    enum Const {
        static let maxCellRepeat: Double = 32 // max number of cells horizontally and vertically
        static let log2CellRepeat: Double = log2(Const.maxCellRepeat) // typically log2(32) = 5
        static let squareSize = 5.5 / 18 // size of single colored square compared to pitch (0.3055555)
        static let animationIntervalSeconds: TimeInterval = 7 // duration of animation in seconds
        static let crossHairsWidth: CGFloat = 2
        static let crossHairsColor: Color = Color(UIColor(white: 0.5, alpha: 0.5))
    }
    private let preludeImageStore = PreludeImageStore2626()
    @State private var preludeImage = PreludeImage(assetName: "2021_FotogroepWaalre_058_square",
                                                   copyright: "© Greetje van Son",
                                                   whiteCoordinates: .init(x: 8, y: 6)) // non-random temp answer

    // MARK: - State variables
    @State private var offsetInCells = OffsetVectorInCells2626(x: 8, y: 8) // # of cell units left/above imagecenter
    @State private var logScale = Const.log2CellRepeat // value driving the animation
    private var isZoomedOut: Bool { abs(logScale) < 0.0001 }
    @State private var willMoveToNextScreen = false // used to navigate to next screen
    @State private var crosshairsVisible = true // displays Crosshairs view, can be toggled via "c" on keyboard
    @State private var debugPanelVisible = false // displays DebugPanel view, can be toggled via "d" on keyboard
    @State private var debugLocation = CGPoint(x: 0, y: 0)
    @Environment(\.horizontalSizeClass) var horSizeClass

    private func zoomInOutAnimated(_ location: CGPoint, geo: GeometryProxy) {
        debugLocation = location // for debugging only
        withAnimation(.easeInOut(duration: Const.animationIntervalSeconds)) {
            if isZoomedOut { // if we are completely zoomed out at the time of the tap
                logScale = log2(Const.maxCellRepeat) // zoom in
                offsetInCells = intOffset(rect: geo.size, location: location)
            } else {
                offsetInCells = OffsetVectorInCells2626(x: 0, y: 0)
                logScale = 0.0 // zoom out
            }
        }
    }

    var body: some View {
        NavigationStack { // defines navigation structure of entire app, even though you don't see navigation bar yet
            ZStack {
                AngularGradient(gradient: Gradient(colors: [.white, .fgwGreen,
                                                            .white, .fgwBlue,
                                                            .white, .fgwGreen,
                                                            .white, .fgwRed,
                                                            .white]
                ), center: .center)
                .saturation(0.5)
                .brightness(0.05)
                .ignoresSafeArea()
                .onTapGesture { // if user taps background, exit animation loop
                    withAnimation(.easeInOut(duration: Const.animationIntervalSeconds)) {
                        willMoveToNextScreen = true
                    }
                }
                .navigate(to: MemberPortfolioListView2626()
                    .navigationBarTitle(String(localized: "Portfolios",
                                               table: "PhotoClubHub.SwiftUI",
                                               comment: "Title of page showing member portfolios")),
                          when: $willMoveToNextScreen,
                          horSizeClass: horSizeClass)

                GeometryReader { geo in
                    ZStack(alignment: .center) {
                        ZStack {
                            Image(preludeImage.assetName)
                                .resizable()
                                .scaledToFit()
                                .brightness(isZoomedOut ? 0.1 : 0.2)
                            Group {
                                LogoPath(logCellRepeat: Const.log2CellRepeat, // upper left part of logo
                                         relPixelSize: Const.squareSize,
                                         offsetPoint: .zero)
                                .fill(.fgwGreen)
                                LogoPath(logCellRepeat: Const.log2CellRepeat, // upper right part of logo
                                         relPixelSize: Const.squareSize,
                                         offsetPoint: .top)
                                .fill(.fgwBlue)
                                LogoPath(logCellRepeat: Const.log2CellRepeat, // lower left part of logo
                                         relPixelSize: Const.squareSize,
                                         offsetPoint: .leading)
                                .fill(.fgwRed)
                                LogoPath(logCellRepeat: Const.log2CellRepeat, // lower righ part of logo
                                         relPixelSize: Const.squareSize,
                                         offsetPoint: .center)
                                .fill(.fgwGreen)
                            }
                            .blendMode(.multiply)
                            .opacity(isZoomedOut ? 0 : 25) // Hack to influence animation: 0 : 1 would alter timing
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
                            zoomInOutAnimated(location, geo: geo)
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                        .task {
                            preludeImage = await preludeImageStore.getRandomPreludeImage()
                            offsetInCells = preludeImage.whiteCoordinates
                        }
                    }

                    CrossHairs2626(hidden: !crosshairsVisible)
                        .stroke(Const.crossHairsColor, lineWidth: Const.crossHairsWidth)
                        .blendMode(.normal)

                    EscapeHatch(willMoveToNextScreen: $willMoveToNextScreen,
                                offset: $offsetInCells,
                                location: $debugLocation,
                                size: geo.size,
                                debugPanelVisible: $debugPanelVisible,
                                crosshairsVisible: $crosshairsVisible)

                    Text(preludeText)
                        .foregroundColor(.black)
                        .font(Font.custom("Gill Sans", size: 105*(min(geo.size.width, geo.size.height)/800))) // was 105
                        .kerning((0/3)*(min(geo.size.width, geo.size.height)/800)) // was 140/3
                        .offset(x: (0/3)*(min(geo.size.width, geo.size.height)/800)) // was 60/3
                        .opacity(isZoomedOut ? 0 : 1)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .onTapGesture { location in
                            zoomInOutAnimated(location, geo: geo)
                        }
                        .dynamicTypeSize(DynamicTypeSize.large ...
                                         DynamicTypeSize.large) // don't let DynamicType change WAALRE size

                } // GeometryReader
                .compositingGroup() // This triggers use of Metal framework
                // .drawingGroup() would also trigger use of Metal framework but gives fopen() warnings on first run
                .padding()

            }
            .navigationBarTitle(String(localized: "Prelude",
                                       table: "PhotoClubHub.SwiftUI",
                                       comment: "Title of the opening animation screen"))
        }

    }

    func offset(frame rect: CGSize) -> CGSize { // used to position large image in the middle of a cell
        guard isZoomedOut == false else { return .zero }
        let shortFrameDimension: Double = min(rect.width, rect.height)
        let cellPitchInPixels: Double = shortFrameDimension/Const.maxCellRepeat
        let offset = CGSize( width: cellPitchInPixels * Double(offsetInCells.x) * pow(2, logScale),
                             height: cellPitchInPixels * Double(offsetInCells.y) * pow(2, logScale) )
        return offset
    }

    func intOffset(rect: CGSize, location: CGPoint) -> OffsetVectorInCells2626 { // to translate tap to selected cell
        guard isZoomedOut == false else { return OffsetVectorInCells2626(x: 0, y: 0) }
        let shortFrameDimension = min(rect.width, rect.height)
        let halfFrameDimension = shortFrameDimension / 2
        let cellPitchInPixels = shortFrameDimension/Const.maxCellRepeat
        return OffsetVectorInCells2626(x: Int((((halfFrameDimension - location.x) / cellPitchInPixels)).rounded()),
                                       y: Int((((halfFrameDimension - location.y) / cellPitchInPixels)).rounded()))
    }

    var preludeText: String {
        if Settings.manualDataLoading {
            String(localized: "Manual loading",
                   table: "PhotoClubHub.SwiftUI",
                   comment: "Shown instead of app name in PreludeView when app is started")
        } else if isDebug {
            String(localized: "In debug mode",
                   table: "PhotoClubHub.SwiftUI",
                   comment: "Shown instead of app name in PreludeView when app is started")
        } else {
            String(localized: "Photo Club Hub",
                   table: "PhotoClubHub.SwiftUI",
                   comment: "Name of the app shown in PreludeView when app is started")
        }
    }

    struct EscapeHatch: View {
        let willMoveToNextScreen: Binding<Bool>
        let offset: Binding<OffsetVectorInCells2626>
        let location: Binding<CGPoint>
        var size: CGSize
        @Binding var debugPanelVisible: Bool
        @Binding var crosshairsVisible: Bool

        var body: some View {
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    DebugPanel2626(size: size, offset: offset, location: location, hidden: !debugPanelVisible)
                    Spacer()
                    Image(systemName: "arrowshape.turn.up.forward.circle")
                        .accessibilityLabel(Text(String(localized: "Next",
                                                        table: "PhotoClubHub.SwiftUI",
                                                        comment: "Button text")))
                        .accessibilityHint(Text((String(localized: "Go to Portfolios screen",
                                                        table: "PhotoClubHub.SwiftUI",
                                                        comment: "Button hint"))))
                        .foregroundStyle(.white)
                        .font(.system(size: 36))
                        .frame(width: 65, height: 65)
                        .glassEffect(.regular.interactive().tint(.blue))
                        .onTapGesture {
                            willMoveToNextScreen.wrappedValue = true
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
                    .keyboardShortcut("d", modifiers: []) // d-key

                    Button {
                        crosshairsVisible.toggle()
                    } label: { EmptyView() }
                    .keyboardShortcut("c", modifiers: []) // c-key
                }
                .font(.title)
            }

        }
    }

}

@available(iOS 26.0, *)
struct OffsetVectorInCells2626 {
    // swiftlint:disable:next identifier_name
    var x, y: Int
}

// MARK: - Preview

@available(iOS 26.0, *)
#Preview("Prelude – Portrait", traits: .portrait) {
    PreludeView2626()
}

@available(iOS 26.0, *)
#Preview("Prelude – Landscape", traits: .landscapeLeft) {
    PreludeView2626()
}

@available(iOS 26.0, *)
#Preview("Prelude – Dark Mode") {
    PreludeView2626()
        .preferredColorScheme(.dark)
}
