//
//  ReadmeSection1718.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 28/01/2025.
//

import SwiftUI

// struct to define some standard view modifiers for use in Readme text sections
@available(iOS, obsoleted: 19.0, message: "Please use 'ReadmeSection2626' for versions about iOS 18.x")
struct ReadmeSection1718: View {
    private let localizedString: LocalizedStringResource
    private let geo: GeometryProxy
    private var bottomPaddingAmount: CGFloat // defaults to value of horizontal padding

    // explicit init() used here just to suppress localizedString argument label
    init(_ localizedString: LocalizedStringResource,
         geo: GeometryProxy,
         bottomPaddingAmount: CGFloat = ReadmeView1718.paddingConstant) {
        self.localizedString = localizedString
        self.geo = geo
        self.bottomPaddingAmount = bottomPaddingAmount
    }

    var body: some View {
        Text(localizedString)
            .padding([.horizontal], ReadmeView1718.paddingConstant)
            .padding([.bottom], bottomPaddingAmount)
            .frame(width: geo.size.width, alignment: .leading)
            .fixedSize() // magic to get Text to wrap
    }
}
