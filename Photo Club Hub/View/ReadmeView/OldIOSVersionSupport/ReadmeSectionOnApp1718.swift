//
//  ReadmeSectionOnApp1718.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/04/2026.
//

import SwiftUI

// https://stackoverflow.com/questions/77735635/how-to-have-a-conditional-modifier-based-on-the-os-version-in-swiftui
@available(iOS, obsoleted: 19.0)
public struct ReadmeSectionOnApp1718: View {
    let geo: GeometryProxy
    public init(geo: GeometryProxy) { self.geo = geo }
    public var body: some View {
        Group {

            ReadmeSectionHeader(LocalizedStringResource("The App",
                                                        table: "PhotoClubHub.Readme",
                                                        comment: "Title of one section of Readme screen"),
                                geo: geo)
            ReadmeSection(LocalizedStringResource("§1.1",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§1.2",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§1.3",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)

            Image("app_screenshots_EN")
                .resizable()
                .border(.gray, width: 1)
                .scaledToFit()
                .frame(width: geo.size.width * 0.8, alignment: .center)
            Text("Clubs, their Members, and their Portfolios\n", tableName: "PhotoClubHub.Readme",
                 comment: "Caption of an image on the Readme page")
            .font(.callout.italic())
            .frame(width: geo.size.width, alignment: .center)
            Text(verbatim: "")

            ReadmeSection(LocalizedStringResource("§1.4",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§1.5",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§1.6",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
        }
    }
}

// https://stackoverflow.com/questions/77735635/how-to-have-a-conditional-modifier-based-on-the-os-version-in-swiftui
@available(iOS, obsoleted: 19.0)
struct ReadmeSectionOnApp1718_Previews: PreviewProvider {
    @State static private var title = "Readme Preview"

    static var previews: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    ReadmeSectionOnApp1718(geo: geo)
                        .preferredColorScheme(.light)
                        .navigationTitle(title)
                        .previewInterfaceOrientation(.portrait)
                }
            }
        }
    }
}
