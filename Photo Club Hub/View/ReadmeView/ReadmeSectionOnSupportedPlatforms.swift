//
//  SectionOnSupportedPlatforms.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/04/2026.
//

import SwiftUI

struct ReadmeSectionOnSupportedPlatforms: View {
    let geo: GeometryProxy
    public init(geo: GeometryProxy) { self.geo = geo }

    var body: some View {
        Group {
            ReadmeSectionHeader(LocalizedStringResource("Supported Platforms",
                                                        table: "PhotoClubHub.Readme",
                                                        comment: "Title of one section of Readme screen"),
                                geo: geo)
            ReadmeSection(LocalizedStringResource("§4.1",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§4.2",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§4.3",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§4.4",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
        }
    }
}

// believe it or not, the following Preview does work
struct ReadmeSectionOnSupportedPlatforms_Previews: PreviewProvider {
    @State static private var title = "Readme Preview"

    static var previews: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    ReadmeSectionOnSupportedPlatforms(geo: geo)
                        .preferredColorScheme(.light)
                        .navigationTitle(title)
                        .previewInterfaceOrientation(.portrait)
                }
            }
        }
    }
}
