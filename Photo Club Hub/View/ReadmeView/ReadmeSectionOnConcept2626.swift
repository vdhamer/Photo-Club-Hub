//
//  ReadmeSectionOnConcept2626.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/04/2026.
//

import SwiftUI

@available(iOS 26.0, *)
public struct ReadmeSectionOnConcept2626: View {
    let geo: GeometryProxy
    public init(geo: GeometryProxy) { self.geo = geo }

    public var body: some View {
        Group {
            SectionHeader(
                LocalizedStringResource("The Concept",
                                        table: "PhotoClubHub.Readme",
                                        comment: "Title of one section of Readme screen"),
                geo: geo
            )
           ReadmeSection2626(
                LocalizedStringResource("§2.1",
                                        table: "PhotoClubHub.Readme",
                                        comment: "Paragraph in the Readme screen"),
                geo: geo)
            ReadmeSection2626(
                LocalizedStringResource("§2.2",
                                        table: "PhotoClubHub.Readme",
                                        comment: "Paragraph in the Readme screen"),
                geo: geo)
            ReadmeSection2626(
                LocalizedStringResource("§2.3",
                                        table: "PhotoClubHub.Readme",
                                        comment: "Paragraph in the Readme screen"),
                geo: geo)
            ReadmeSection2626(
                LocalizedStringResource("§2.4",
                                        table: "PhotoClubHub.Readme",
                                        comment: "Paragraph in the Readme screen"),
                geo: geo)
            ReadmeSection2626(
                LocalizedStringResource("§2.5",
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

@available(iOS 26.0, *)
struct ReadmeSectionOnConcept2626_Previews: PreviewProvider {
    @State static private var title = "Readme Preview"

    static var previews: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    ReadmeSectionOnConcept2626(geo: geo)
                        .preferredColorScheme(.light)
                        .navigationTitle(title)
                        .previewInterfaceOrientation(.portrait)
                }
            }
        }
    }
}
