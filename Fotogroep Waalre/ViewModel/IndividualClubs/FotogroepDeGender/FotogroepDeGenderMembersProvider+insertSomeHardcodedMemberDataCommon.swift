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

    private static let deGenerURL = URL(string: "https://www.fcdegender.nl")
    private static let fotogroepDeGenderIdPlus = PhotoClubIdPlus(fullName: "Fotogroep de Gender",
                                                                 town: "Eindhoven",
                                                                 nickname: "FG deGender")

    func insertSomeHardcodedMemberData(bgContext: NSManagedObjectContext) {
        bgContext.perform { // from here on, we are running on a background thread
            self.insertSomeHardcodedMemberDataCommon(bgContext: bgContext)
        }
    }

    // swiftlint:disable:next function_body_length
    private func insertSomeHardcodedMemberDataCommon(bgContext: NSManagedObjectContext) {

        // add De Gender to Photo Clubs (if needed)
        let clubDeGender = PhotoClub.findCreateUpdate(
                                                        context: bgContext,
                                                        photoClubIdPlus: Self.fotogroepDeGenderIdPlus,
                                                        photoClubWebsite: FotogroepDeGenderMembersProvider.deGenerURL,
                                                        fotobondNumber: 1620, kvkNumber: nil,
                                                        coordinates: CLLocationCoordinate2D(latitude: 51.42398,
                                                                                            longitude: 5.45010)
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
                  photoClub: clubDeGender,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [.chairman: true]),
                  memberWebsite: URL(string: "https://www.fcdegender.nl/wp-content/uploads/Expositie%202023/Mariet/"),
                  latestImage: URL(string:
                     "https://www.fcdegender.nl/wp-content/uploads/Expositie%202023/Mariet/slides/Mariet%203.jpg")
        )

        addMember(bgContext: bgContext, // add Peter to members of de Gender
                  personName: PersonName(givenName: "Peter", infixName: "van den", familyName: "Hamer"),
                  photoClub: clubDeGender,
                  latestImage: URL(string:
                     "http://www.vdhamer.com/wp-content/uploads/2023/11/PeterVanDenHamer.jpg")
        )

        addMember(bgContext: bgContext, // add Peter to members of de Gender
                  personName: PersonName(givenName: "Bettina", infixName: "de", familyName: "Graaf"),
                  photoClub: clubDeGender,
                  memberRolesAndStatus: MemberRolesAndStatus(stat: [.prospective: true]),
                  latestImage: URL(string:
                     "http://www.vdhamer.com/wp-content/uploads/2023/11/BettinaDeGraaf.jpeg")
        )

        let clubNickname = FotogroepDeGenderMembersProvider.fotogroepDeGenderIdPlus.nickname

        do {
            if bgContext.hasChanges {
                try bgContext.save() // commit all changes
            }
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
