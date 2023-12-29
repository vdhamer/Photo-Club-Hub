//
//  TestClubRotterdamMembersProvider+insertSomeHardcodedMemberData.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 01/08/2021.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension TestClubRotterdamMembersProvider { // fill with some initial hard-coded content

    private static let testRotterdamURL = URL(string: "https://www.nederlandsfotomuseum.nl")
    static let photoClubTestRotterdamIdPlus = PhotoClubIdPlus(fullName: "Test Fotoclub",
                                                              town: "Rotterdam",
                                                              nickname: "FC Test Rdam")

    func insertSomeHardcodedMemberData(bgContext: NSManagedObjectContext) {
        bgContext.perform {
            self.insertSomeHardcodedMemberDataCommon(bgContext: bgContext)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(bgContext: NSManagedObjectContext) {

        // add photo club to Photo Clubs (if needed)
        let clubTestRotterdam = PhotoClub.findCreateUpdate(
                                            context: bgContext,
                                            organizationType: .club,
                                            photoClubIdPlus: Self.photoClubTestRotterdamIdPlus,
                                            photoClubWebsite: TestClubRotterdamMembersProvider.testRotterdamURL,
                                            fotobondNumber: nil, kvkNumber: nil,
                                            coordinates: CLLocationCoordinate2D(latitude: 51.90296, longitude: 4.49504)
                                            )

        ifDebugPrint("""
                     \(clubTestRotterdam.fullNameTown): \
                     Starting insertSomeHardcodedMemberData() in background
                     """)
        clubTestRotterdam.hasHardCodedMemberData = true // store in database that we ran insertSomeHardcodedMembers...

        addMember(bgContext: bgContext,
                  personName: PersonName(givenName: "Peter", infixName: "van den", familyName: "Hamer"),
                  photoClub: clubTestRotterdam,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true ], stat: [ .former: false]),
                  memberWebsite: URL(string: "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testR")!,
                  latestImage: URL(string:
                     "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testR/" +
		                                    "thumbs/2015_Madeira_RX1r_064.jpg"),
                  phoneNumber: nil,
                  eMail: "foobarR@vdhamer.com"
        )

        do {
//            if bgContext.hasChanges {
                try bgContext.save() // // persist Test Club Rotterdam and its memberss
//            }
            ifDebugPrint("""
                         \(clubTestRotterdam.fullNameTown): \
                         Completed insertSomeHardcodedMemberData() in background
                         """)
        } catch {
            ifDebugFatalError("Failed to save changes for Test Rotterdam",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, failing to store the data is only logged. And the app doesn't stop.
        }

    }

    private func addMember(bgContext: NSManagedObjectContext,
                           personName: PersonName,
                           bornDT: Date? = nil,
                           photoClub: PhotoClub,
                           memberRolesAndStatus: MemberRolesAndStatus = MemberRolesAndStatus(role: [:], stat: [:]),
                           memberWebsite: URL? = nil,
                           latestImage: URL? = nil,
                           latestThumbnail: URL? = nil,
                           phoneNumber: String? = nil,
                           eMail: String? = nil) {

        let photographer = Photographer.findCreateUpdate(
                            context: bgContext,
                            personName: personName,
                            memberRolesAndStatus: memberRolesAndStatus,
                            bornDT: bornDT,
                            photoClub: photoClub)

        let image = latestImage ?? latestThumbnail // if image not available, use thumbnail (which might also be nil)
        let thumb = latestThumbnail ?? latestImage // if thumb not available, use image (which might also be nil)
        _ = MemberPortfolio.findCreateUpdate(
                            bgContext: bgContext, photoClub: photoClub, photographer: photographer,
                            memberRolesAndStatus: memberRolesAndStatus,
                            memberWebsite: memberWebsite,
                            latestImage: image,
                            latestThumbnail: thumb)
    }

}
