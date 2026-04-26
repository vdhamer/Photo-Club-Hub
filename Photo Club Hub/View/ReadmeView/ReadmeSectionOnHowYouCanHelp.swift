//
//  ReadmeSectionOnHowYouCanHelp.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/04/2026.
//

import SwiftUI

struct ReadmeSectionOnHowYouCanHelp: View {
    let geo: GeometryProxy
    public init(geo: GeometryProxy) { self.geo = geo }

    var body: some View {
        Group {
            ReadmeSectionHeader(LocalizedStringResource("How you can help",
                                                        table: "PhotoClubHub.Readme",
                                                        comment: "Title of one section of Readme screen"),
                                geo: geo)
            ReadmeSection(LocalizedStringResource("§5.1",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§5.2",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)

            ReadmeCaptionedImage("Bellus_Imago_Level_1",
                                 imageSize: CGSize(width: geo.size.width * 0.9, height: UIDevice.isIPad ? 500 : 250),
                                 caption: LocalizedStringResource("Configuring Level 1 data for a Dutch photo club",
                                                                  table: "PhotoClubHub.Readme",
                                                                  comment: "Caption for image on Readme page"))

            ReadmeSection(LocalizedStringResource("§5.3",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§5.4",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§5.5",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo,
                          bottomPaddingAmount: 0)

            ReadmeCaptionedImage("Swift_enum",
                                 imageSize: CGSize(width: geo.size.width * 0.9, height: UIDevice.isIPad ? 500 : 250),
                                 caption: LocalizedStringResource("Fragment of the Swift source code",
                                                                  table: "PhotoClubHub.Readme",
                                                                  comment: "Caption for image on Readme page"))
        }
    }
}

struct ReadmeSectionOnHowYouCanHelp_Previews: PreviewProvider {
    @State static private var title = "Readme Preview"

    static var previews: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    ReadmeSectionOnHowYouCanHelp(geo: geo)
                        .preferredColorScheme(.light)
                        .navigationTitle(title)
                        .previewInterfaceOrientation(.portrait)
                }
            }
        }
    }
}
