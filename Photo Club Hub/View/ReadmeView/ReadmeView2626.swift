//
//  ReadmeView2626.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/03/2022.
//

import SwiftUI

@available(iOS 26.0, *)
// swiftlint:disable:next type_body_length
struct ReadmeView2626: View {

    @Environment(\.dismiss) var dismiss: DismissAction
    @State private var showingRoadmap = false // controls visibility of Preferences screen

    static let paddingConstant: CGFloat = 20
    private let title = String(localized: "Readme",
                               table: "PhotoClubHub.Readme",
                               comment: "Title of Readme screen")

    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        Group {

                            SectionHeader2626(LocalizedStringResource("The App", table: "PhotoClubHub.Readme",
                                                                  comment: "Title of one section of Readme screen"),
                                                                  geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§1.1", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§1.2", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§1.3", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)

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

                            ReadmeSection2626(LocalizedStringResource("§1.4", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§1.5", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§1.6", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                        }

                        Group {
                            SectionHeader2626(LocalizedStringResource("The Concept", table: "PhotoClubHub.Readme",
                                                                  comment: "Title of one section of Readme screen"),
                                                                  geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§2.1", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§2.2", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§2.3", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§2.4", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§2.5", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)

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

                        Group {

                            SectionHeader2626(LocalizedStringResource("Features and Tips", table: "PhotoClubHub.Readme",
                                                                  comment: "Title of one section of Readme screen"),
                                                                  geo: geo)

                            ReadmeSection2626(LocalizedStringResource("§3.01.a", table: "PhotoClubHub.Readme",
                                                                  comment: "Title of a section of the Readme screen"),
                                                                  geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.01.b", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"),
                                                                  geo: geo, bottomPaddingAmount: 0)

                            Image("Search-bar-bottom")
                                .resizable()
                                .scaledToFit()
                                .frame(width: geo.size.width * 0.8, height: 260, alignment: .center)
                            Text("Search bar of _Portfolios_ screen (for iOS 26 and up)",
                                 tableName: "PhotoClubHub.Readme",
                                 comment: "Caption about Search Bar on the Readme page")
                            .font(.callout.italic())
                            Text(verbatim: "")

                            ReadmeSection2626(LocalizedStringResource("§3.01.c", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)

                            ReadmeSection2626(LocalizedStringResource("§3.02.a", table: "PhotoClubHub.Readme",
                                                                  comment: "Title of a section of the Readme screen"),
                                                                  geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.02.b", table: "PhotoClubHub.Readme",
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

                            ReadmeSection2626(LocalizedStringResource("§3.02.c", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)

                            ReadmeSection2626(LocalizedStringResource("§3.03.a", table: "PhotoClubHub.Readme",
                                                                  comment: "Title of a section of the Readme screen"),
                                                                  geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.03.b", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)

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

                            ReadmeSection2626(LocalizedStringResource("§3.04.a", table: "PhotoClubHub.Readme",
                                                                  comment: "Title of a section of the Readme screen"),
                                                                  geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.04.b", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)

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

                            ReadmeSection2626(LocalizedStringResource("§3.05.a", table: "PhotoClubHub.Readme",
                                                                  comment: "Title of a section of the Readme screen"),
                                                                  geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.05.b", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.05.c", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)

                            ReadmeSection2626(LocalizedStringResource("§3.06.a", table: "PhotoClubHub.Readme",
                                                                  comment: "Title of a section of the Readme screen"),
                                                                  geo: geo)
                            let persistenceController = PersistenceController.shared // for Core Data
                            let viewContext = persistenceController.container.viewContext
                            // -2 is to not count XampleMin and XampleMax
                            let orgCount = Organization.count(context: viewContext,
                                                              organizationTypeE: OrganizationTypeEnum.club) - 2
                            ReadmeSection2626(LocalizedStringResource("§3.06.b \(orgCount)", // dynamic via query
                                                                  table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.06.c", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.06.d", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)

                            ReadmeSection2626(LocalizedStringResource("§3.07.a", table: "PhotoClubHub.Readme",
                                                                  comment: "Title of a section of the Readme screen"),
                                                                  geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.07.b", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.07.c", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)

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

                            ReadmeSection2626(LocalizedStringResource("§3.08.a", table: "PhotoClubHub.Readme",
                                                                  comment: "Title of a section of the Readme screen"),
                                                                  geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.08.b", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)

                            ReadmeSection2626(LocalizedStringResource("§3.09.a", table: "PhotoClubHub.Readme",
                                                                  comment: "Title of a section of the Readme screen"),
                                                                  geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.09.b", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)

                            Image("Website")
                                .resizable()
                                .scaledToFit()
                                .border(.gray, width: 1)
                                .frame(width: geo.size.width * 0.6, alignment: .center)
                            Text("Example of a link to a club web site", tableName: "PhotoClubHub.Readme",
                                 comment: "Caption of Websites image on Readme page")
                            .font(.callout.italic())
                            .frame(width: geo.size.width, alignment: .center)
                            Text(verbatim: "")

                            ReadmeSection2626(LocalizedStringResource("§3.10.a", table: "PhotoClubHub.Readme",
                                                                  comment: "Title of a section of the Readme screen"),
                                                                  geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.10.b", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.10.c", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.10.d", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.10.e", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)

                            Image("2021_FotogroepWaalre_058")
                                .resizable()
                                .frame(width: 250, height: 375, alignment: .center)
                                .scaledToFill()
                                .border(.gray, width: 1)
                                .frame(width: geo.size.width, alignment: .center)
                            Text(verbatim: "© Greetje van Son\n")
                                .font(.callout.italic())
                                .frame(width: geo.size.width, alignment: .center)

                            ReadmeSection2626(LocalizedStringResource("§3.11.a", table: "PhotoClubHub.Readme",
                                                                  comment: "Title of a section of the Readme screen"),
                                                                  geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.11.b", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.11.c", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)

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

                            ReadmeSection2626(LocalizedStringResource("§3.12.a", table: "PhotoClubHub.Readme",
                                                                  comment: "Title of a section of the Readme screen"),
                                                                  geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.12.b", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§3.12.c", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)

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

                        Group {
                            SectionHeader2626(LocalizedStringResource("Supported Platforms",
                                                                      table: "PhotoClubHub.Readme",
                                                                      comment: "Title of one section of Readme screen"),
                                              geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§4.1", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§4.2", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§4.3", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                            ReadmeSection2626(LocalizedStringResource("§4.4", table: "PhotoClubHub.Readme",
                                                                  comment: "Paragraph in the Readme screen"), geo: geo)
                        }

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

                        SectionHeader2626(LocalizedStringResource("", table: "PhotoClubHub.Readme",
                                                              comment: "Empty section header"),
                                      geo: geo)

                    } // outer VStack

                } // ScrollView
                .navigationTitle(title)
            }
            .padding(.init(top: 0, leading: 0, bottom: 15, trailing: 0))
            .presentationSizing(.page)
        } // GeometryReader
    }

}

// MARK: - Preview

@available(iOS 26.0, *)
struct ReadmeView2626_Previews: PreviewProvider {
    @State static private var title = "Info Preview"

    static var previews: some View {
        ReadmeView2626()
            .preferredColorScheme(.light)
            .navigationTitle(title)
            .previewInterfaceOrientation(.portrait)
    }
}
