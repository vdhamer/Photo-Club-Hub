//
//  ReadmeSection.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 28/01/2025.
//

import SwiftUI

// struct to define some standard view modifiers for use in Readme text sections
struct ReadmeSection: View {
    private let localizedString: LocalizedStringResource
    private let geo: GeometryProxy
    private var bottomPaddingAmount: CGFloat // defaults to value of horizontal padding

    // explicit init() used here just to suppress localizedString argument label
    init(_ localizedString: LocalizedStringResource,
         geo: GeometryProxy,
         bottomPaddingAmount: CGFloat = ReadmeSectionHeader.paddingConstant) {
        self.localizedString = localizedString
        self.geo = geo
        self.bottomPaddingAmount = bottomPaddingAmount
    }

    var body: some View {
        Text(localizedString)
            .padding([.horizontal], ReadmeSectionHeader.paddingConstant)
            .padding([.bottom], bottomPaddingAmount)
            .frame(width: geo.size.width, alignment: .leading)
            .fixedSize() // magic to get Text to wrap
    }
}

// believe it or not, the following Preview does work
struct ReadmeSection_Previews: PreviewProvider {
    @State static private var title = "ReadmeSection Preview"

    static var previews: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    Divider()
                    ReadmeSection(
                        LocalizedStringResource("§1.1",
                                                table: "PhotoClubHub.Readme",
                                                comment: "Preview sample from The App section"),
                        geo: geo
                    )
                    ReadmeSection(
                        LocalizedStringResource("§1.2",
                                                table: "PhotoClubHub.Readme",
                                                comment: "Preview sample from The App section"),
                        geo: geo,
                        bottomPaddingAmount: 0
                    )
                    Divider()
                }
                .navigationTitle(title)
                .preferredColorScheme(.light)
                .previewInterfaceOrientation(.portrait)
            }
        }
    }
}
