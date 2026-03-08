//
//  SectionHeader2626.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 28/01/2025.
//

import SwiftUI

@available(iOS 26.0, *)
struct SectionHeader2626: View {
    private let localizedString: LocalizedStringResource
    private let geo: GeometryProxy

    // explicit init() used here just to suppress localizedStringKey argument label
    init(_ localizedString: LocalizedStringResource, geo: GeometryProxy) {
        self.localizedString = localizedString
        self.geo = geo
    }

    var body: some View {
        let boxCount: Int = UIDevice.isIPad ? 7 : 3 // number of boxes to left or right of chapter title
        let const1: CGFloat = 0.8
        let const2: CGFloat = 0.05
        let const3: CGFloat = const1 - const2 * CGFloat(boxCount - 1)

        HStack {
            ForEach(0..<boxCount, id: \.self) { integer in
                Image(systemName: "square.fill")
                    .foregroundColor((boxCount-integer-1) % 3 == 0 ? .fgwBlue :
                                        (boxCount-integer-1) % 3 == 1 ? .fgwGreen : .fgwRed)
                    .scaleEffect(const3 + const2 * CGFloat(integer))
            }
            Text(self.localizedString) // can receive an empty string
                .foregroundColor(.linkColor)
                .allowsTightening(true)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .font(.title3)
            ForEach(0..<boxCount, id: \.self) { integer in
                Image(systemName: "square.fill")
                    .foregroundColor(integer % 3 == 0 ? .fgwBlue :
                                        integer % 3 == 1 ? .fgwGreen : .fgwRed)
                    .scaleEffect(const1 - const2 * CGFloat(integer))
            }
        }
        .frame(width: geo.size.width * 0.9, height: 50, alignment: .center)
        .padding(Edge.Set([.horizontal]), ReadmeView2626.paddingConstant)
    }
}
