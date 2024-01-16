//
//  AndersMembersProvider+InsertSomeHardcodedMemberData.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 29/10/2023.
//

import CoreData // for NSManagedObjectContext
import Foundation // for date processing
import MapKit // for CLLocationCoordinate2D

extension AndersMembersProvider { // fill with some initial hard-coded content

    private static let andersURL = URL(string: "https://nl.qrcodechimp.com/page/a6d3r7?v=chk1697032881")
    private static let fotogroepAndersIdPlus = PhotoClubIdPlus(fullName: "Fotogroep Anders",
                                                               town: "Eindhoven",
                                                               nickname: "FG Anders")

    func insertSomeHardcodedMemberData(bgContext: NSManagedObjectContext) {
        bgContext.perform { // from here on, we are running on a background thread
            self.insertSomeHardcodedMemberDataCommon(bgContext: bgContext)
        }
    }

    // swiftlint:disable:next function_body_length
    private func insertSomeHardcodedMemberDataCommon(bgContext: NSManagedObjectContext) {

        // add De Gender to Photo Clubs (if needed)
        let clubAnders = PhotoClub.findCreateUpdate(
                                                    context: bgContext,
                                                    organizationTypeEum: .club,
                                                    photoClubIdPlus: Self.fotogroepAndersIdPlus // ,
//                                                    photoClubWebsite: AndersMembersProvider.andersURL,
//                                                    fotobondNumber: nil, kvkNumber: nil,
                                                    // coordinates point to Kruisruimte, Generaal Bothastraat, Eindhoven
//                                                    coordinates: CLLocationCoordinate2D(latitude: 51.44297,
//                                                                                        longitude: 5.51527)
                                                   )

        ifDebugPrint("""
                     \(clubAnders.fullNameTown): \
                     Starting insertSomeHardcodedMemberData() in background
                     """)
        clubAnders.hasHardCodedMemberData = true // store in database that we ran insertSomeHardcodedMembers...

        addMember(bgContext: bgContext, // add Loek to Photographers and member of Bellus (if needed)
                  personName: PersonName(givenName: "Helga", infixName: "", familyName: "Nuchelmans"),
                  photoClub: clubAnders,
                  memberWebsite: URL(string: "https://helganuchelmans.nl"),
                  latestImage: URL(string: """
                                           https://cdn.myportfolio.com/\
                                           d8801b208f49ae95bc80b15c07cde6f2/\
                                           902cb616-6aaf-4f1f-9d40-3487d0e1254a_rw_1200.jpg\
                                           ?h=7fee8b232bc10216ccf294e69a81be4c
                                           """)
        )

        addMember(bgContext: bgContext, // add Loek to Photographers and member of Bellus (if needed)
                  personName: PersonName(givenName: "Mirjam", infixName: "", familyName: "Evers"),
                  photoClub: clubAnders,
                  memberWebsite: URL(string: "https://me4photo.jimdosite.com/portfolio/"),
                  latestImage: URL(string: """
                                           https://jimdo-storage.freetls.fastly.net/\
                                           image/bf4d707f-ff72-4e16-8f2f-63680e7a8f91.jpg\
                                           ?format=pjpg&quality=80,90&auto=webp&disable=upscale&width=2560&height=2559
                                           """)
        )

        addMember(bgContext: bgContext, // add Loek to Photographers and member of Bellus (if needed)
                  personName: PersonName(givenName: "Lotte", infixName: "", familyName: "Vrij"),
                  photoClub: clubAnders,
//                  memberWebsite: URL(string: "https://lotte-vrij-fotografie.jimdofree.com"),
                  memberWebsite: URL(string: "https://www.fotogroepwaalre.nl/fotos/Empty_Website/"),
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

        addMember(bgContext: bgContext, // add Loek to Photographers and member of Bellus (if needed)
                  personName: PersonName(givenName: "Dennis", infixName: "", familyName: "Verbruggen"),
                  photoClub: clubAnders,
                  memberWebsite: URL(string: "https://www.fotogroepwaalre.nl/fotos/Empty_Website/"),
                  latestImage: URL(string: "http://www.vdhamer.com/wp-content/uploads/2023/11/DennisVerbruggen.jpeg")
        )

        do {
//            if bgContext.hasChanges {
                try bgContext.save() // persist FG Anders and its members
                print("*** Updating *** SAVING instance=\"\(clubAnders.fullName)\"")
//            }
            ifDebugPrint("""
                         \(clubAnders.fullNameTown): \
                         Completed insertSomeHardcodedMemberData() in background
                         """)
        } catch {
            let clubNickname = AndersMembersProvider.fotogroepAndersIdPlus.nickname

            ifDebugFatalError("\(clubNickname): ERROR - failed to save changes to Core Data",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, the failed database update is only logged. App doesn't stop.
        }

    }

    private func addMember(bgContext: NSManagedObjectContext,
                           personName: PersonName,
                           photographerWebsite: URL? = nil,
                           bornDT: Date? = nil,
                           photoClub: PhotoClub,
                           memberRolesAndStatus: MemberRolesAndStatus = MemberRolesAndStatus(role: [:], stat: [:]),
                           memberWebsite: URL? = nil,
                           latestImage: URL? = nil,
                           latestThumbnail: URL? = nil,
                           phoneNumber: String? = nil,
                           eMail: String? = nil) {
        let photographer = Photographer.findCreateUpdate(context: bgContext,
                                                         personName: personName,
                                                         memberRolesAndStatus: memberRolesAndStatus,
                                                         photographerWebsite: photographerWebsite,
                                                         bornDT: bornDT,
                                                         photoClub: photoClub)

        let image = latestImage ?? latestThumbnail // if image not available, use thumbnail (which might also be nil)
        let thumb = latestThumbnail ?? latestImage // if thumb not available, use image (which might also be nil)
        _ = MemberPortfolio.findCreateUpdate(bgContext: bgContext, photoClub: photoClub, photographer: photographer,
                                             memberRolesAndStatus: memberRolesAndStatus,
                                             memberWebsite: memberWebsite,
                                             latestImage: image,
                                             latestThumbnail: thumb)
    }

}
