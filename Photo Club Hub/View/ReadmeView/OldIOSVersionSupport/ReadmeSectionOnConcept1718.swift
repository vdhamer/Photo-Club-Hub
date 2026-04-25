//
//  ReadmeSectionOnConcept1718.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/04/2026.
//

import SwiftUI

// https://stackoverflow.com/questions/77735635/how-to-have-a-conditional-modifier-based-on-the-os-version-in-swiftui
@available(iOS, obsoleted: 19.0)
struct ReadmeSectionOnConcept1718: View {
    let geo: GeometryProxy
    public init(geo: GeometryProxy) { self.geo = geo }

    var body: some View {
        Group {
            SectionHeader(LocalizedStringResource("The Concept",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of one section of Readme screen"),
                          geo: geo)
            ReadmeSection1718(LocalizedStringResource("§2.1",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§2.2",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§2.3",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§2.4",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§2.5",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)

            Image("Waalre_AppIcon")
                .resizable()
                .scaledToFit()
                .frame(width: geo.size.width * 0.4, alignment: .center)
                .border(.gray, width: 1)
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                    Text("You are running app version \(version) (build \(build))",
                         tableName: "PhotoClubHub.Readme",
                         comment: "Shown on Readme page.")
                    .font(.callout.italic())
                    .frame(width: geo.size.width, alignment: .center)
                    Text(verbatim: "")
                }
            }
        }
    }
}

// https://stackoverflow.com/questions/77735635/how-to-have-a-conditional-modifier-based-on-the-os-version-in-swiftui
@available(iOS, obsoleted: 19.0)
struct ReadmeSectionOnConcept1718_Previews: PreviewProvider {
    @State static private var title = "Readme Preview"

    static var previews: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    ReadmeSectionOnConcept1718(geo: geo)
                        .preferredColorScheme(.light)
                        .navigationTitle(title)
                        .previewInterfaceOrientation(.portrait)
                }
            }
        }
    }
}
