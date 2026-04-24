//
//  ReadmeSectionOnApp2626.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/04/2026.
//

import SwiftUI

@available(iOS 26.0, *)
public struct ReadmeSectionOnApp2626: View {
    let geo: GeometryProxy

    public init(geo: GeometryProxy) { self.geo = geo }

    public var body: some View {
        Group {
            SectionHeader2626(
                LocalizedStringResource("The App",
                                        table: "PhotoClubHub.Readme",
                                        comment: "Title of one section of Readme screen"),
                geo: geo
            )
            ReadmeSection2626(
                LocalizedStringResource("§1.1",
                                        table: "PhotoClubHub.Readme",
                                        comment: "The App section paragraph 1.1"),
                geo: geo
            )
            ReadmeSection2626(
                LocalizedStringResource("§1.2",
                                        table: "PhotoClubHub.Readme",
                                        comment: "The App section paragraph 1.2"),
                geo: geo
            )
            ReadmeSection2626(
                LocalizedStringResource("§1.3",
                                        table: "PhotoClubHub.Readme",
                                        comment: "The App section paragraph 1.3"),
                geo: geo
            )

            Image("app_screenshots_EN")
                .resizable()
                .border(.gray, width: 1)
                .scaledToFit()
                .frame(width: geo.size.width * 0.8, alignment: .center)
            Text(
                LocalizedStringResource(
                    "Clubs, their Members, and their Portfolios\n",
                    table: "PhotoClubHub.Readme",
                    comment: "Caption of an image on the Readme page"
                )
            )
            .font(.callout.italic())
            .frame(width: geo.size.width, alignment: .center)
            Text(verbatim: "")

            ReadmeSection2626(
                LocalizedStringResource("§1.4",
                                        table: "PhotoClubHub.Readme",
                                        comment: "The App section paragraphs 1.4"),
                geo: geo
            )
            ReadmeSection2626(
                LocalizedStringResource("§1.5",
                                        table: "PhotoClubHub.Readme",
                                        comment: "The App section paragraphs 1.5"),
                geo: geo
            )
            ReadmeSection2626(
                LocalizedStringResource("§1.6",
                                        table: "PhotoClubHub.Readme",
                                        comment: "The App section paragraphs 1.6"),
                geo: geo
            )
        }
    }
}

@available(iOS 26.0, *)
#Preview {
    GeometryReader {geo in
        ReadmeSectionOnApp2626(geo: geo)
    }
}
