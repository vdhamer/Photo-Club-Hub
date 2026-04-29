//
//  ReadmeSectionOnFeaturesAndTips.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 24/04/2026.
//

import SwiftUI

struct ReadmeSectionOnFeaturesAndTips: View {
    let geo: GeometryProxy
    public init(geo: GeometryProxy) { self.geo = geo }
    // Minor differences between the iOS 26 and 17/18 versions are handled by logic rather than having 2 file copies
    private var iOS2626: Bool { if #available(iOS 26, *) { true } else { false } }

    var body: some View {
        Group {

            ReadmeSectionHeader(LocalizedStringResource("Features and Tips",
                                                        table: "PhotoClubHub.Readme",
                                                        comment: "Title of one section of Readme screen"),
                                geo: geo)

            ReadmeSection(LocalizedStringResource("§3.01.a",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of a section of the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.01.b",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo, bottomPaddingAmount: 0)

            if iOS2626 {
                ReadmeCaptionedImage("Search-bar-bottom",
                                     imageSize: CGSize(width: geo.size.width * 0.8, height: 260),
                                     caption: LocalizedStringResource(
                                        "Search bar of _Portfolios_ screen (for iOS 26 and up)",
                                        table: "PhotoClubHub.Readme",
                                        comment: "Figure caption about Search Bar on the Readme page"
                                     )
                )
            } else {
                ReadmeCaptionedImage("Search-bar-top",
                                     imageSize: CGSize(width: geo.size.width * 0.8, height: 260),
                                     caption: LocalizedStringResource(
                                        "The search bar is at the top of the screen (for iOS versions up to 18).",
                                        table: "PhotoClubHub.Readme",
                                        comment: "Figure caption about Search Bar on the Readme page")
                )
            }

            ReadmeSection(LocalizedStringResource("§3.01.c",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)

            ReadmeSection(LocalizedStringResource("§3.02.a",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of a section of the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.02.b",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo, bottomPaddingAmount: 0)
            ReadmeCaptionedImage("Expertise",
                                 imageSize: CGSize(width: geo.size.width * 0.8, height: 260),
                                 caption: LocalizedStringResource("Supported (🏵) and temporary (🪲) expertise tags",
                                                                  table: "PhotoClubHub.Readme",
                                                                  comment:
                                                                   "Figure caption about Expertise on the Readme page"))

            ReadmeSection(LocalizedStringResource("§3.02.c",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)

            ReadmeSection(LocalizedStringResource("§3.03.a",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of a section of the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.03.b",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeCaptionedImage("Localizations",
                                 imageSize: CGSize(width: geo.size.width * 0.95, height: UIDevice.isIPad ? 250 : 100),
                                 caption: LocalizedStringResource("Part of the internal translation table",
                                                                  table: "PhotoClubHub.Readme",
                                                                  comment:
                                                                       "Caption of Localizations image on Readme page"))

            ReadmeSection(LocalizedStringResource("§3.04.a",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of a section of the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.04.b",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeCaptionedImage("3D_map",
                                 imageSize: CGSize(width: geo.size.width * 0.8, height: UIDevice.isIPad ? 450 : 200),
                                 caption: LocalizedStringResource("Maps can be viewed in 3D",
                                                                  table: "PhotoClubHub.Readme",
                                                                  comment: "Caption of 3D image on Readme page"))

            ReadmeSection(LocalizedStringResource("§3.05.a",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of a section of the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.05.b",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeCaptionedImage("photographerimage",
                                 imageSize: CGSize(width: geo.size.width * 0.95, height: 75),
                                 caption: LocalizedStringResource("You can set a preference for thumbnails",
                                                                  table: "PhotoClubHub.Readme",
                                                                  comment: "Image caption on Readme page"))
            ReadmeSection(LocalizedStringResource("§3.05.c",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)

            ReadmeSection(LocalizedStringResource("§3.06.a",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of a section of the Readme screen"),
                          geo: geo)
            let persistenceController = PersistenceController.shared // for Core Data
            let viewContext = persistenceController.container.viewContext
            // -2 is not counting TemplateMin and TemplateMax
            let orgCount = Organization.count(context: viewContext,
                                              organizationTypeE: OrganizationTypeEnum.club) - 2
            ReadmeSection(LocalizedStringResource("§3.06.b \(orgCount)", // dynamic via query
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.06.c",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.06.d",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)

            ReadmeSection(LocalizedStringResource("§3.07.a",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of a section of the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.07.b",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.07.c",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeCaptionedImage("Maps",
                                 imageSize: CGSize(width: geo.size.width * 0.95, height: UIDevice.isIPad ? 400 : 200),
                                 caption: LocalizedStringResource("Amsterdam has two photography museums.",
                                                                  table: "PhotoClubHub.Readme",
                                                                  comment: "Example of a link to a club web site"))

            ReadmeSection(LocalizedStringResource("§3.08.a",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of a section of the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.08.b",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)

            ReadmeSection(LocalizedStringResource("§3.09.a",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of a section of the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.09.b",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeCaptionedImage("Website",
                                 imageSize: CGSize(width: geo.size.width * 0.7, height: UIDevice.isIPad ? 300 : 250),
                                 caption: LocalizedStringResource("Example of a link to a club web site",
                                                                  table: "PhotoClubHub.Readme",
                                                                  comment: "Example of a link to a club web site"))

            ReadmeSection(LocalizedStringResource("§3.10.a",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of a section of the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.10.b",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.10.c",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.10.d",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.10.e",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeCaptionedImage("2021_FotogroepWaalre_058",
                                 imageSize: CGSize(width: 250, height: 375),
                                 caption: LocalizedStringResource("© Greetje van Son",
                                                                  table: "PhotoClubHub.Readme",
                                                                  comment: "Caption of an image on the Readme page"))

            ReadmeSection(LocalizedStringResource("§3.11.a",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of a section of the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.11.b",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.11.c",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeCaptionedImage("Preferences",
                                 imageSize: CGSize(width: geo.size.width * 0.8, height: 400),
                                 caption: LocalizedStringResource("The Preferences screen.",
                                                                  table: "PhotoClubHub.Readme",
                                                                  comment: "Caption of an image on the Readme page"))
            Text(verbatim: "")

            ReadmeSection(LocalizedStringResource("§3.12.a",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of a section of the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.12.b",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.12.c",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)

            ReadmeCaptionedImage("Play-button",
                                 imageSize: CGSize(width: geo.size.width * 0.8, height: 300),
                                 caption: LocalizedStringResource("Buttons for the automatic slide show",
                                                                  table: "PhotoClubHub.Readme",
                                                                  comment:
                                                                        "Caption about Play button on the Readme page"))
            Text(verbatim: "")

            ReadmeSection(LocalizedStringResource("§3.13.a",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Title of a section of the Readme screen"),
                          geo: geo)
            ReadmeSection(LocalizedStringResource("§3.13.b",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)
            ReadmeCaptionedImage("FotobondNL",
                                 imageSize: CGSize(width: geo.size.width * 0.8, height: UIDevice.isIPad ? 500 : 400),
                                 caption: LocalizedStringResource("Highlighted clubs are part of the Fotobond",
                                                                  table: "PhotoClubHub.Readme",
                                                                  comment:
                                                                        "Caption about Fotobond clubs on Readme page"))
            ReadmeSection(LocalizedStringResource("§3.13.c",
                                                  table: "PhotoClubHub.Readme",
                                                  comment: "Paragraph in the Readme screen"),
                          geo: geo)

            Text(verbatim: "")

        }
    }
}

// believe it or not, the following Preview does work
struct ReadmeSectionOnFeaturesAndTips_Previews: PreviewProvider {
    @State static private var title = "Readme Preview"

    static var previews: some View {
        GeometryReader { geo in
            NavigationStack {
                ScrollView(.vertical, showsIndicators: true) {
                    ReadmeSectionOnFeaturesAndTips(geo: geo)
                        .preferredColorScheme(.light)
                        .navigationTitle(title)
                        .previewInterfaceOrientation(.portrait)
                }
            }
        }
    }
}
