//
//  ReadmeSectionOnHowYouCanHelp2626.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/04/2026.
//

import SwiftUI

@available(iOS 26.0, *)
public struct ReadmeSectionOnHowYouCanHelp2626: View {
    let geo: GeometryProxy
    public init(geo: GeometryProxy) { self.geo = geo }

    public var body: some View {
        Group {
            SectionHeader2626(LocalizedStringResource("How you can help", table: "PhotoClubHub.Readme",
                                                  comment: "Title of one section of Readme screen"),
                                                  geo: geo)
            ReadmeSection2626(LocalizedStringResource("§5.1", table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"), geo: geo)
            ReadmeSection2626(LocalizedStringResource("§5.2", table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"), geo: geo)

            VStack {
                Image("Bellus_Imago_Level_1")
                    .resizable()
                    .border(.gray, width: 1)
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.8, alignment: .center)
                Text("Configuring Level 1 data for a Dutch photo club",
                     tableName: "PhotoClubHub.Readme",
                     comment: "Caption for image on Readme page")
                .font(.callout.italic())
                .frame(width: geo.size.width, alignment: .center)
                Text(verbatim: "")
            }

            ReadmeSection2626(LocalizedStringResource("§5.3", table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"), geo: geo)
            ReadmeSection2626(LocalizedStringResource("§5.4", table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"), geo: geo)
            ReadmeSection2626(LocalizedStringResource("§5.5", table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"), geo: geo,
                          bottomPaddingAmount: 0)

            VStack {
                Image("Swift_enum")
                    .resizable()
                    .border(.gray, width: 1)
                    .scaledToFit()
                    .frame(width: geo.size.width * 0.8, alignment: .center)
                Text("Fragment of the Swift source code", tableName: "PhotoClubHub.Readme",
                     comment: "Caption for image on Readme page")
                    .font(.callout.italic())
                    .frame(width: geo.size.width, alignment: .center)
                Text(verbatim: "")
            }
        }
    }
}

@available(iOS 26.0, *)
struct ReadmeSectionOnHowYouCanHelp2626_Previews: PreviewProvider {
    @State static private var title = "Readme Preview"

    static var previews: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    ReadmeSectionOnHowYouCanHelp2626(geo: geo)
                        .preferredColorScheme(.light)
                        .navigationTitle(title)
                        .previewInterfaceOrientation(.portrait)
                }
            }
        }
    }
}
