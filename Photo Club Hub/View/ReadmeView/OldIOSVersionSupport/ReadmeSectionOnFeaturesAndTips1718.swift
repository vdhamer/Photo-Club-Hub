//
//  ReadmeSectionOnFeaturesAndTips1718.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/04/2026.
//

import SwiftUI

struct ReadmeSectionOnFeaturesAndTips1718: View {
    let geo: GeometryProxy
    public init(geo: GeometryProxy) { self.geo = geo }

    var body: some View {
        Group {

            SectionHeader(LocalizedStringResource("Features and Tips",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of one section of Readme screen"),
                              geo: geo)

            ReadmeSection1718(LocalizedStringResource("§3.01.a",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Title of a section of the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.01.b",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo, bottomPaddingAmount: 0)

            Image("Search-bar-top")
                .resizable()
                .scaledToFit()
                .frame(width: geo.size.width * 0.8, height: 260, alignment: .center)
            Text("Search bar of _Portfolios_ screen (up to iOS 18)",
                 tableName: "PhotoClubHub.Readme",
                 comment: "Caption about Search Bar on the Readme page")
            .font(.callout.italic())
            .frame(width: geo.size.width * 0.8, alignment: .center)
            Text(verbatim: "")

            ReadmeSection1718(LocalizedStringResource("§3.01.c",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)

            ReadmeSection1718(LocalizedStringResource("§3.02.a",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Title of a section of the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.02.b",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo, bottomPaddingAmount: 0)

            Text(verbatim: "")
            Image("Expertise")
                .resizable()
                .border(.gray, width: 1)
                .scaledToFit()
                .frame(width: geo.size.width * 0.8, height: 260, alignment: .center)
            Text("Supported (🏵) and temporary (🪲) expertise tags", tableName: "PhotoClubHub.Readme",
                 comment: "Caption about Expertise on the Readme page")
            .font(.callout.italic())
            .frame(width: geo.size.width * 0.8, alignment: .center)
            Text(verbatim: "")

            ReadmeSection1718(LocalizedStringResource("§3.02.c",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)

            ReadmeSection1718(LocalizedStringResource("§3.03.a",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Title of a section of the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.03.b",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)

            Image("Localizations") // belongs to Section 3.1
                .resizable()
                .scaledToFit()
                .frame(width: geo.size.width * 0.8, alignment: .center)
            Text("Part of the internal translation table", tableName: "PhotoClubHub.Readme",
                 comment: "Caption of Localizations image on Readme page")
            .font(.callout.italic())
            .frame(width: geo.size.width, alignment: .center)
            Text(verbatim: "")
            Text(verbatim: "")

            ReadmeSection1718(LocalizedStringResource("§3.04.a",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Title of a section of the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.04.b",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)

            Image("3D_map") // belongs to Section 3.2
                .resizable()
                .scaledToFit()
                .frame(width: geo.size.width * 0.8, alignment: .center)
                .border(.gray, width: 1)
            Text("Maps can be viewed in 3D", tableName: "PhotoClubHub.Readme",
                 comment: "Caption of 3D image on Readme page")
            .font(.callout.italic())
            .frame(width: geo.size.width, alignment: .center)
            Text(verbatim: "")

            ReadmeSection1718(LocalizedStringResource("§3.05.a",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Title of a section of the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.05.b",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.05.c",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)

            ReadmeSection1718(LocalizedStringResource("§3.06.a",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Title of a section of the Readme screen"),
                              geo: geo)
            let persistenceController = PersistenceController.shared // for Core Data
            let viewContext = persistenceController.container.viewContext
            // -2 is not counting TemplateMin and TemplateMax
            let orgCount = Organization.count(context: viewContext,
                                              organizationTypeE: OrganizationTypeEnum.club) - 2
            ReadmeSection1718(LocalizedStringResource("§3.06.b \(orgCount)", // dynamic via query
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.06.c",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.06.d",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)

            ReadmeSection1718(LocalizedStringResource("§3.07.a",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Title of a section of the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.07.b",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.07.c",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)

            Image("Maps") // belongs to Section 3.5
                .resizable()
                .scaledToFit()
                .frame(width: geo.size.width * 0.8, alignment: .center)
                .border(.gray, width: 1)
            Text("Amsterdam has two photography museums.", tableName: "PhotoClubHub.Readme",
                 comment: "Caption of Museums image on Readme page")
            .font(.callout.italic())
            .frame(width: geo.size.width, alignment: .center)
            Text(verbatim: "")

            ReadmeSection1718(LocalizedStringResource("§3.08.a",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Title of a section of the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.08.b",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)

            ReadmeSection1718(LocalizedStringResource("§3.09.a",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Title of a section of the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.09.b",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)

            Image("Website")
                .resizable()
                .scaledToFit()
                .border(.gray, width: 1)
                .frame(width: geo.size.width * 0.6, alignment: .center)
            Text("Example of a link to a club web site",
                 tableName: "PhotoClubHub.Readme",
                 comment: "Caption of Websites image on Readme page")
            .font(.callout.italic())
            .frame(width: geo.size.width, alignment: .center)
            Text(verbatim: "")

            ReadmeSection1718(LocalizedStringResource("§3.10.a",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Title of a section of the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.10.b",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.10.c",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.10.d",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.10.e",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)

            Image("2021_FotogroepWaalre_058")
                .resizable()
                .frame(width: 250, height: 375, alignment: .center)
                .scaledToFill()
                .border(.gray, width: 1)
                .frame(width: geo.size.width, alignment: .center)
            Text(verbatim: "© 2021 Greetje van Son\n")
                .font(.callout.italic())
                .frame(width: geo.size.width, alignment: .center)

            ReadmeSection1718(LocalizedStringResource("§3.11.a",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Title of a section of the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.11.b",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.11.c",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)

            Image("Preferences")
                .resizable()
                .border(.gray, width: 1)
                .scaledToFit()
                .frame(width: geo.size.width * 0.8, height: 300, alignment: .center)
            Text("The Preferences screen.", tableName: "PhotoClubHub.Readme",
                 comment: "Caption of an image on the Readme page")
            .font(.callout.italic())
            .frame(width: geo.size.width * 0.8, alignment: .center)
            Text(verbatim: "")

            ReadmeSection1718(LocalizedStringResource("§3.12.a",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Title of a section of the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.12.b",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)
            ReadmeSection1718(LocalizedStringResource("§3.12.c",
                                                      table: "PhotoClubHub.Readme",
                                                      comment: "Paragraph in the Readme screen"),
                              geo: geo)

            Image("Play-button")
                .resizable()
                .border(.gray, width: 1)
                .scaledToFit()
                .frame(width: geo.size.width * 0.8, height: 300, alignment: .center)
            Text("Buttons for the automatic slide show", tableName: "PhotoClubHub.Readme",
                 comment: "Caption about Play button on the Readme page")
            .font(.callout.italic())
            .frame(width: geo.size.width * 0.8, alignment: .center)
            Text(verbatim: "")

        }
    }
}

// https://stackoverflow.com/questions/77735635/how-to-have-a-conditional-modifier-based-on-the-os-version-in-swiftui
@available(iOS, obsoleted: 19.0)
struct ReadmeSectionOnFeaturesAndTips1718_Previews: PreviewProvider {
    @State static private var title = "Readme Preview"

    static var previews: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    ReadmeSectionOnFeaturesAndTips1718(geo: geo)
                        .preferredColorScheme(.light)
                        .navigationTitle(title)
                        .previewInterfaceOrientation(.portrait)
                }
            }
        }
    }
}
