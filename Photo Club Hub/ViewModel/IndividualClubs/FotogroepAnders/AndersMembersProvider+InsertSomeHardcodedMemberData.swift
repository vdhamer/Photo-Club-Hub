//
//  AndersMembersProvider+InsertSomeHardcodedMemberData.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 29/10/2023.
//

import CoreData // for NSManagedObjectContext
import Foundation // for date processing
import MapKit // for CLLocationCoordinate2D

extension AndersMembersProvider { // fill with some initial hard-coded content

    private static let andersURL = URL(string: "https://nl.qrcodechimp.com/page/a6d3r7?v=chk1697032881")
    private static let fotogroepAndersIdPlus = OrganizationIdPlus(fullName: "Fotogroep Anders",
                                                                  town: "Eindhoven",
                                                                  nickname: "FG Anders")

    func insertSomeHardcodedMemberData(bgContext: NSManagedObjectContext) {
        bgContext.perform { // from here on, we are running on a background thread
            self.insertSomeHardcodedMemberDataCommon(bgContext: bgContext)
            do {
                if bgContext.hasChanges { // optimisation
                    try bgContext.save() // persist FG Anders and its online member data (on private context)
                    print("Sucess loading FG Anders member data")
                }
            } catch {
                ifDebugFatalError("Error saving members of FG Anders: \(error.localizedDescription)")
            }
        }
    }

    // swiftlint:disable:next function_body_length
    private func insertSomeHardcodedMemberDataCommon(bgContext: NSManagedObjectContext) {

        // add De Gender to Photo Clubs (if needed)
        let clubAnders = Organization.findCreateUpdate(
                                                    context: bgContext,
                                                    organizationTypeEnum: .club,
                                                    idPlus: Self.fotogroepAndersIdPlus
                                                   )

        ifDebugPrint("""
                     \(clubAnders.fullNameTown): \
                     Starting insertSomeHardcodedMemberData() in background
                     """)
        clubAnders.hasHardCodedMemberData = true // store in database that we ran insertSomeHardcodedMembers...


        addMember(bgContext: bgContext, // add Dennis to Photographers and member of Anders (if needed)
                  personName: PersonName(givenName: "Dennis", infixName: "", familyName: "Verbruggen"),
                  organization: clubAnders,
                  memberWebsite: URL(string: FotogroepWaalreMembersProvider.baseURL + "/Empty_Website/"),
                  latestImage: URL(string: "http://www.vdhamer.com/wp-content/uploads/2023/11/DennisVerbruggen.jpeg")
        )

        addMember(bgContext: bgContext, // add Helga to Photographers and member of Anders (if needed)
                  personName: PersonName(givenName: "Helga", infixName: "", familyName: "Nuchelmans"),
                  organization: clubAnders,
                  memberWebsite: URL(string: "https://helganuchelmans.nl"),
                  latestImage: URL(string: """
                                           https://cdn.myportfolio.com/\
                                           d8801b208f49ae95bc80b15c07cde6f2/\
                                           902cb616-6aaf-4f1f-9d40-3487d0e1254a_rw_1200.jpg\
                                           ?h=7fee8b232bc10216ccf294e69a81be4c
                                           """)
        )

        addMember(bgContext: bgContext, // add Lotte to Photographers and member of Anders (if needed)
                  personName: PersonName(givenName: "Lotte", infixName: "", familyName: "Vrij"),
                  organization: clubAnders,
                  // website: URL(string: "https://lotte-vrij-fotografie.jimdofree.com"),
                  memberWebsite: URL(string: FotogroepWaalreMembersProvider.baseURL + "Empty_Website/"),
                  latestImage: URL(string: """
                                           https://image.jimcdn.com/app/cms/image/transf/none/path/\
                                           sb2e92183adfb60fb/image/ie69f110f416b6822/version/1678882175/image.jpg
                                           """),
                  latestThumbnail: URL(string: """
                                               https://image.jimcdn.com/app/cms/image/transf/\
                                               dimension=150x150:mode=crop:format=jpg/path/\
                                               sb2e92183adfb60fb/image/ie69f110f416b6822/version/1678882175/image.jpg
                                               """)
        )

        addMember(bgContext: bgContext, // add Mirjam to Photographers and member of Anders (if needed)
                  personName: PersonName(givenName: "Mirjam", infixName: "", familyName: "Evers"),
                  organization: clubAnders,
                  memberWebsite: URL(string: "https://me4photo.jimdosite.com/portfolio/"),
                  latestImage: URL(string: """
                                           https://jimdo-storage.freetls.fastly.net/\
                                           image/bf4d707f-ff72-4e16-8f2f-63680e7a8f91.jpg\
                                           ?format=pjpg&quality=80,90&auto=webp&disable=upscale&width=2560&height=2559
                                           """)
        )

    }

    private func addMember(bgContext: NSManagedObjectContext,
                           personName: PersonName,
                           website: URL? = nil,
                           bornDT: Date? = nil,
                           organization: Organization,
                           memberRolesAndStatus: MemberRolesAndStatus = MemberRolesAndStatus(role: [:], status: [:]),
                           memberWebsite: URL? = nil,
                           latestImage: URL? = nil,
                           latestThumbnail: URL? = nil,
                           phoneNumber: String? = nil,
                           eMail: String? = nil) {

        let photographer = Photographer.findCreateUpdate(context: bgContext,
                                                         personName: personName,
                                                         isDeceased: memberRolesAndStatus.isDeceased(),
                                                         website: website,
                                                         bornDT: bornDT,
                                                         organization: organization
                                                         )

        let image = latestImage ?? latestThumbnail // if image not available, use thumbnail (which might also be nil)
        let thumb = latestThumbnail ?? latestImage // if thumb not available, use image (which might also be nil)
        _ = MemberPortfolio.findCreateUpdate(bgContext: bgContext,
                                             organization: organization, photographer: photographer,
                                             memberRolesAndStatus: memberRolesAndStatus,
                                             memberWebsite: memberWebsite,
                                             latestImage: image,
                                             latestThumbnail: thumb
                                             )
    }

}
