//
//  LockAnimationView.swift
//
//  Created by Amos Gyamfi on 17.3.2020.
//  Copyright © 2020 Amos Gyamfi. All rights reserved.
//

import SwiftUI

struct LockAnimationView: View {
    // https://github.com/amosgyamfi/swiftui-animation-library/blob/master/unlock.zip
    var locked: Bool
    var lineWidth: Double = 2.3
    var lineColor: Color = .organizationColor

    var body: some View {
        GeometryReader { geo in
            ZStack {

                RoundedRectangle(cornerRadius: min(geo.size.width, geo.size.height)*0.15, style: .continuous)
                    .inset(by: lineWidth)
                    .strokeBorder(lineColor, lineWidth: lineWidth)
                    .cornerRadius(min(geo.size.width, geo.size.height)*0.01)
                    .foregroundColor(.white)
                    .offset(y: 13)
                    .frame(width: min(geo.size.width, geo.size.height)*0.45,
                           height: min(geo.size.width, geo.size.height)*0.40)

                Capsule()
                    .trim(from: locked ? 0.60 : 0.60,
                          to: locked ? 0.90: 0.95)
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .frame(width: min(geo.size.width, geo.size.height)*0.20,
                           height: min(geo.size.width, geo.size.height)*0.5)
                    .foregroundColor(lineColor)
                    .offset(y: min(geo.size.width, geo.size.height) * (locked ? 0.20 : 0.10))
                    .rotation3DEffect(.degrees(locked ? 0 : 180),
                                      axis: (x: 0, y: -1, z: 0),
                                      anchor: .topTrailing,
                                      anchorZ: 0, perspective: 1)

                Circle()
                    .scaleEffect(0.07)
                    .offset(y: min(geo.size.width, geo.size.height) * 0.18)
                    .foregroundColor(.gray)

                Rectangle()
                    .scaleEffect(CGSize(width: 0.03, height: 0.10))
                    .offset(y: min(geo.size.width, geo.size.height) * 0.23)
                    .foregroundColor(.secondary)

            }
            .offset(x: 7, y: -9) // shifted slightly upwards from previous .offset(x: 7, y: -7)
            .rotationEffect(.degrees(locked ? 0 : 15))
            .animation(Animation.easeInOut(duration: 0.3), value: locked)
        }
    }
}

struct LockAnimation_Previews: PreviewProvider {
    @State private var locked: Bool = true

    static var previews: some View {
        GeometryReader { geo in
            LockAnimationView(locked: true, lineWidth: 10, lineColor: .teal)
                .frame(width: min(geo.size.width, geo.size.height),
                       height: min(geo.size.width, geo.size.height))
                .frame(width: geo.size.width, height: geo.size.height)
                .border(.red, width: 1)
        }
    }
}
