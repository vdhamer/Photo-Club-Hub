//
//  PreludeView1718.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 05/03/2022.
//

import SwiftUI

@available(iOS, obsoleted: 19.0, message: "Please use 'PreludeView2626' for versions about iOS 18.x")
struct PreludeView1718: View {

    // MARK: - Constants
    static let maxCellRepeat: Double = 32 // max number of cells horizontally and vertically
    fileprivate static let log2CellRepeat: Double = log2(maxCellRepeat) // typically log2(32) = 5
    fileprivate static let squareSize = 5.5 / 18 // size of single colored square compared to pitch (0.3055555)
    fileprivate let crossHairsWidth: CGFloat = 2
    fileprivate let crossHairsColor: Color = Color(UIColor(white: 0.5, alpha: 0.5))

    // MARK: - State variables
    @State fileprivate var offsetInCells = OffsetVectorInCells1718(x: 8, y: 6) // # of cell units left/above imagecenter
    @State fileprivate var logScale = log2CellRepeat // value driving the animation
    @State fileprivate var willMoveToNextScreen = false // used to navigate to next screen
    @State fileprivate var crosshairsVisible = true // displays Crosshairs view, can be toggled via "c" on keyboard
    @State fileprivate var debugPanelVisible = false // displays DebugPanel view, can be toggled via "d" on keyboard
    @State fileprivate var debugLocation = CGPoint(x: 0, y: 0)
    @Environment(\.horizontalSizeClass) var horSizeClass

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
                    withAnimation(.easeInOut(duration: 7)) {
                        willMoveToNextScreen = true
                    }
                }
                .navigate(to: MemberPortfolioListView1718().navigationBarTitle("Portfolios"),
                          when: $willMoveToNextScreen,
                          horSizeClass: horSizeClass)

                GeometryReader { geo in
                    ZStack(alignment: .center) {
                        ZStack {
                            Image("2021_FotogroepWaalre_058_square")
                                .resizable()
                                .scaledToFit()
                                .brightness(logScale == 0  ? 0.1 : 0.2)
                            Group {
                                LogoPath(logCellRepeat: PreludeView1718.log2CellRepeat, // upper left part of logo
                                         relPixelSize: PreludeView1718.squareSize,
                                         offsetPoint: .zero)
                                .fill(.fgwGreen)
                                LogoPath(logCellRepeat: PreludeView1718.log2CellRepeat, // upper right part of logo
                                         relPixelSize: PreludeView1718.squareSize,
                                         offsetPoint: .top)
                                .fill(.fgwBlue)
                                LogoPath(logCellRepeat: PreludeView1718.log2CellRepeat, // lower left part of logo
                                         relPixelSize: PreludeView1718.squareSize,
                                         offsetPoint: .leading)
                                .fill(.fgwRed)
                                LogoPath(logCellRepeat: PreludeView1718.log2CellRepeat, // lower righ part of logo
                                         relPixelSize: PreludeView1718.squareSize,
                                         offsetPoint: .center)
                                .fill(.fgwGreen)
                            }
                            .blendMode(.multiply)
                            .opacity(logScale == 0  ? 0.5 : 1)
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
                                    logScale = log2(PreludeView1718.maxCellRepeat) // zoom in
                                    offsetInCells = intOffset(rect: geo.size, location: location)
                                } else {
                                    offsetInCells = OffsetVectorInCells1718(x: 0, y: 0)
                                    logScale = 0.0 // zoom out
                                }
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    }

                    CrossHairs(hidden: !crosshairsVisible)
                        .stroke(crossHairsColor, lineWidth: crossHairsWidth)
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
                        .opacity(logScale == 0  ? 0 : 1)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .onTapGesture { location in
                            debugLocation = location // for debugging only
                            ifDebugPrint("Tap location: (\(location.x),\(location.y))")
                            withAnimation(.easeInOut(duration: 7)) { // carefull: code is duplicated twice ;-(
                                if logScale == 0.0 { // if we are completely zoomed out at the time of the tap
                                    logScale = log2(PreludeView1718.maxCellRepeat) // zoom in
                                    offsetInCells = intOffset(rect: geo.size, location: location)
                                } else {
                                    offsetInCells = OffsetVectorInCells1718(x: 0, y: 0)
                                    logScale = 0.0 // zoom out
                                }
                            }
                        }
                        .dynamicTypeSize(DynamicTypeSize.large ...
                                         DynamicTypeSize.large) // don't let DynamicType change WAALRE size

                } // GeometryReader
                .compositingGroup() // This triggers use of Metal framework
                // .drawingGroup() would also trigger use of Metal framework but gives fopen() warnings on first run
                .padding()

            }
            .navigationBarTitle(String(localized: "Prelude",
                                       comment: "Title of the opening animation screen"))
        }

    }

    func offset(frame rect: CGSize) -> CGSize { // used to position large image in the middle of a cell
        guard logScale != 0 else { return .zero }
        let shortFrameDimension: Double = min(rect.width, rect.height)
        let cellPitchInPixels: Double = shortFrameDimension/PreludeView1718.maxCellRepeat
        let offset = CGSize( width: cellPitchInPixels * Double(offsetInCells.x) * pow(2, logScale),
                             height: cellPitchInPixels * Double(offsetInCells.y) * pow(2, logScale) )
        return offset
    }

    func intOffset(rect: CGSize, location: CGPoint) -> OffsetVectorInCells1718 { // to translate tap to selected cell
        guard logScale != 0 else { return OffsetVectorInCells1718(x: 0, y: 0) }
        let shortFrameDimension = min(rect.width, rect.height)
        let halfFrameDimension = shortFrameDimension / 2
        let cellPitchInPixels = shortFrameDimension/PreludeView1718.maxCellRepeat
        return OffsetVectorInCells1718(x: Int((((halfFrameDimension - location.x) / cellPitchInPixels)).rounded()),
                                       y: Int((((halfFrameDimension - location.y) / cellPitchInPixels)).rounded()))
    }

    var preludeText: String {
        if Settings.manualDataLoading {
            String(localized: "Manual loading",
                   comment: "Shown instead of app name in PreludeView when app is started")
        } else if isDebug {
            String(localized: "In debug mode",
                   comment: "Shown instead of app name in PreludeView when app is started")
        } else {
            String(localized: "Photo Club Hub",
                   comment: "Name of the app shown in PreludeView when app is started")
        }
    }

    struct EscapeHatch: View {
        let willMoveToNextScreen: Binding<Bool>
        let offset: Binding<OffsetVectorInCells1718>
        let location: Binding<CGPoint>
        var size: CGSize
        @Binding var debugPanelVisible: Bool
        @Binding var crosshairsVisible: Bool

        var body: some View {
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    DebugPanel1718(size: size, offset: offset, location: location, hidden: !debugPanelVisible)
                    Spacer()
                    Button {
                        willMoveToNextScreen.wrappedValue = true
                    } label: {
                        Image(systemName: "arrowshape.turn.up.forward.circle")
                            .font(.largeTitle)
                    }
                    .keyboardShortcut(.defaultAction) // return key
                    .buttonStyle(.bordered)

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

@available(iOS, obsoleted: 19.0, message: "Please use 'OffsetVectorInCells2626' for versions about iOS 18.x")
struct OffsetVectorInCells1718 {
    // swiftlint:disable:next identifier_name
    var x, y: Int
}

@available(iOS, obsoleted: 19.0, message: "Please use 'PreviewProvider2626' for versions about iOS 18.x")
struct Prelude1718_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreludeView1718()
                .previewInterfaceOrientation(.portrait)
            PreludeView1718()
                .previewInterfaceOrientation(.landscapeLeft)
            PreludeView1718()
                .environment(\.colorScheme, .dark)
        }
    }
}
