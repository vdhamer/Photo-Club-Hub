//
//  ReadmeSectionOnApp.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/04/2026.
//

import SwiftUI

public struct ReadmeSectionOnApp: View {
    let geo: GeometryProxy
    public init(geo: GeometryProxy) { self.geo = geo }

    public var body: some View {
        Group {

            ReadmeSectionHeader(LocalizedStringResource("The App",
                                                        table: "PhotoClubHub.Readme",
                                                        comment: "Title of one section of Readme screen"),
                                geo: geo
            )
            ReadmeSection(LocalizedStringResource("§1.1",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "The App section paragraph 1.1"),
                          geo: geo
            )
            ReadmeSection( LocalizedStringResource("§1.2",
                                                   table: "PhotoClubHub.Readme",
                                                   comment: "The App section paragraph 1.2"),
                           geo: geo
            )
            ReadmeSection( LocalizedStringResource("§1.3",
                                                   table: "PhotoClubHub.Readme",
                                                   comment: "The App section paragraph 1.3"),
                           geo: geo
            )

            ReadmeCaptionedImage("app_screenshots_EN",
                                 imageSize: CGSize(width: geo.size.width * 0.9, height: UIDevice.isIPad ? 500 : 250),
                                 caption: LocalizedStringResource("Clubs, their Members, and their Portfolios",
                                                                  table: "PhotoClubHub.Readme",
                                                                  comment: "Caption for image on Readme page"))

            ReadmeSection(LocalizedStringResource("§1.4",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "The App section paragraphs 1.4"),
                          geo: geo
            )
            ReadmeSection(LocalizedStringResource("§1.5",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "The App section paragraphs 1.5"),
                          geo: geo
            )
            ReadmeSection(LocalizedStringResource("§1.6",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "The App section paragraphs 1.6"),
                          geo: geo
            )
        }
    }
}

// believe it or not, the following Preview does work
struct ReadmeSectionOnApp2626_Previews: PreviewProvider {
    @State static private var title = "Readme/App Preview"

    static var previews: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    ReadmeSectionOnApp(geo: geo)
                        .preferredColorScheme(.light)
                        .navigationTitle(title)
                        .previewInterfaceOrientation(.portrait)
                }
            }
        }
    }
}
