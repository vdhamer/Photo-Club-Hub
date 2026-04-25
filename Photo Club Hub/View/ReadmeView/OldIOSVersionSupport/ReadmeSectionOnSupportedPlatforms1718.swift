//
//  ReadmeSectionOnSupportedPlatforms1718.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/04/2026.
//

import SwiftUI

struct ReadmeSectionOnSupportedPlatforms1718: View {
    let geo: GeometryProxy
    public init(geo: GeometryProxy) { self.geo = geo }

    var body: some View {
        Group {
            SectionHeader(LocalizedStringResource("Supported Platforms",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of one section of Readme screen"),
                          geo: geo)
            ReadmeSection1718(LocalizedStringResource("§4.1", table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§4.2", table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§4.3", table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§4.4", table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                              geo: geo)
        }
    }
}

// https://stackoverflow.com/questions/77735635/how-to-have-a-conditional-modifier-based-on-the-os-version-in-swiftui
@available(iOS, obsoleted: 19.0)
struct ReadmeSectionOnSupportedPlatforms1718_Previews: PreviewProvider {
    @State static private var title = "Readme Preview"

    static var previews: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    ReadmeSectionOnSupportedPlatforms1718(geo: geo)
                        .preferredColorScheme(.light)
                        .navigationTitle(title)
                        .previewInterfaceOrientation(.portrait)
                }
            }
        }
    }
}
