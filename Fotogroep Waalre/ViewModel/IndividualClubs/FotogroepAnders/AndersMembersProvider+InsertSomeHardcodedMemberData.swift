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
            ifDebugPrint("""
                         \(Self.fotogroepAndersIdPlus.fullNameTown): \
                         Starting insertSomeHardcodedMemberData() in background
                         """)
            self.insertSomeHardcodedMemberDataCommon(bgContext: bgContext)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(bgContext: NSManagedObjectContext) {

        // add De Gender to Photo Clubs (if needed)
        let clubAnders = PhotoClub.findCreateUpdate(
                                                    context: bgContext,
                                                    photoClubIdPlus: Self.fotogroepAndersIdPlus,
                                                    photoClubWebsite: AndersMembersProvider.andersURL,
                                                    fotobondNumber: nil, kvkNumber: nil,
                                                    coordinates: CLLocationCoordinate2D(latitude: 51.441850, // temp
                                                                                        longitude: 5.480055) // temp
                                                   )
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

        let clubNickname = AndersMembersProvider.fotogroepAndersIdPlus.nickname

        do {
            if bgContext.hasChanges {
                try bgContext.save() // commit all changes
            }
            ifDebugPrint("""
                         \(Self.fotogroepAndersIdPlus.fullNameTown): \
                         Completed insertSomeHardcodedMemberData() in background
                         """)
        } catch {
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
