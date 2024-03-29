//
//  FotogroepDeGenderMembersProvider+insertSomeHardcodedMemberDataCommon.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 29/09/2023.
//

import CoreData // for NSManagedObjectContext
import Foundation // for date processing
import MapKit // for CLLocationCoordinate2D

extension FotogroepDeGenderMembersProvider { // fill with some initial hard-coded content

    private static let deGenderURL = URL(string: "https://www.fcdegender.nl")
    private static let fotogroepDeGenderIdPlus = OrganizationIdPlus(fullName: "Fotogroep de Gender",
                                                                    town: "Eindhoven",
                                                                    nickname: "FG deGender")

    func insertSomeHardcodedMemberData(bgContext: NSManagedObjectContext) {
        bgContext.perform {
            self.insertSomeHardcodedMemberDataCommon(bgContext: bgContext) // perform inserts on a background thread
        }
    }

    private func insertSomeHardcodedMemberDataCommon(bgContext: NSManagedObjectContext) {

        // add De Gender to Photo Clubs (if needed)
        let clubDeGender = Organization.findCreateUpdate(
                                                        context: bgContext,
                                                        organizationTypeEum: .club,
                                                        idPlus: Self.fotogroepDeGenderIdPlus
                                                     )
        ifDebugPrint("""
                     \(clubDeGender.fullNameTown): \
                     Starting insertSomeHardcodedMemberData() in background
                     """)
        clubDeGender.hasHardCodedMemberData = true // store in database that we ran insertSomeHardcodedMembers...

        let isoDate = "1954-10-09T00:12:00.000000Z"
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let bornDT = dateFormatter.date(from: isoDate)!

        addMember(bgContext: bgContext, // add Mariet to members of de Gender
                  personName: PersonName(givenName: "Mariet", infixName: "", familyName: "Wielders"),
                  photographerWebsite: URL(string: "https://www.m3w.nl"),
                  bornDT: bornDT,
                  organization: clubDeGender,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [.chairman: false]),
                  memberWebsite: URL(string: "https://www.fcdegender.nl/wp-content/uploads/Expositie%202023/Mariet/"),
                  latestImage: URL(string:
                     "https://www.fcdegender.nl/wp-content/uploads/Expositie%202023/Mariet/slides/Mariet%203.jpg")
        )

        addMember(bgContext: bgContext, // add Peter to members of de Gender
                  personName: PersonName(givenName: "Peter", infixName: "van den", familyName: "Hamer"),
                  organization: clubDeGender,
                  memberRolesAndStatus: MemberRolesAndStatus(stat: [.prospective: false]),
                  latestImage: URL(string:
                     "http://www.vdhamer.com/wp-content/uploads/2023/11/PeterVanDenHamer.jpg")
        )

        addMember(bgContext: bgContext, // add Peter to members of de Gender
                  personName: PersonName(givenName: "Bettina", infixName: "de", familyName: "Graaf"),
                  organization: clubDeGender,
                  memberRolesAndStatus: MemberRolesAndStatus(stat: [.prospective: false]),
                  latestImage: URL(string:
                     "http://www.vdhamer.com/wp-content/uploads/2023/11/BettinaDeGraaf.jpeg")
        )

        let clubNickname = FotogroepDeGenderMembersProvider.fotogroepDeGenderIdPlus.nickname

        do {
//            if bgContext.hasChanges {
                try bgContext.save() // persist Fotogroep de Gender and its members
                print("*** Updating *** SAVING instance=\"\(clubDeGender.fullName)\"")
//            }
            ifDebugPrint("""
                         \(clubDeGender.fullNameTown): \
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
                           organization: Organization,
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
                                                         organization: organization)

        let image = latestImage ?? latestThumbnail // if image not available, use thumbnail (which might also be nil)
        let thumb = latestThumbnail ?? latestImage // if thumb not available, use image (which might also be nil)
        _ = MemberPortfolio.findCreateUpdate(bgContext: bgContext,
                                             organization: organization, photographer: photographer,
                                             memberRolesAndStatus: memberRolesAndStatus,
                                             memberWebsite: memberWebsite,
                                             latestImage: image,
                                             latestThumbnail: thumb)
    }

}
