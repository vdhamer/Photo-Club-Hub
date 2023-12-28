//
//  TestClubAmsterdamMembersProvider+insertSomeHardcodedMemberData.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 11/01/2023.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension TestClubAmsterdamMembersProvider { // fill with some initial hard-coded content

    private static let testAmsterdamURL = URL(string: "https://www.foam.org")
    static let photoClubTestAmsterdamIdPlus = PhotoClubIdPlus(fullName: "Test Fotoclub",
                                                              town: "Amsterdam", // Rotterdam also has a "Test Fotoclub"
                                                              nickname: "FC Test Adam")

    func insertSomeHardcodedMemberData(bgContext: NSManagedObjectContext) {
        bgContext.perform {
            self.insertSomeHardcodedMemberDataCommon(bgContext: bgContext)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(bgContext: NSManagedObjectContext) {

        // add photo club to Photo Clubs (if needed)
        let clubTestAmsterdam = PhotoClub.findCreateUpdate(
                                                context: bgContext,
                                                organizationType: .club,
                                                photoClubIdPlus: Self.photoClubTestAmsterdamIdPlus,
                                                photoClubWebsite: TestClubAmsterdamMembersProvider.testAmsterdamURL,
                                                fotobondNumber: nil, kvkNumber: nil,
                                                coordinates: CLLocationCoordinate2D(latitude: 52.364217,
                                                                                    longitude: 4.893370)
                                                )
        ifDebugPrint("""
                     \(clubTestAmsterdam.fullNameTown): \
                     Starting insertSomeHardcodedMemberData() in background
                     """)
        clubTestAmsterdam.hasHardCodedMemberData = true // store in database that we ran insertSomeHardcodedMembers...

        addMember(bgContext: bgContext,
                  personName: PersonName(givenName: "Peter",
                                         infixName: "van den", familyName: "Hamer"),
                  photoClub: clubTestAmsterdam,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .secretary: true ], stat: [ .former: false]),
                  memberWebsite: URL(string: "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testA")!,
                  latestImage: URL(string:
                     "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testA/" +
                                                    "thumbs/2022_Iceland_R5_013.jpg"),
                  eMail: "foobarA@vdhamer.com"
        )

        do {
            if bgContext.hasChanges { // is this necessary? sometimes save() done earlier
                try bgContext.save() // commit all changes
            }
            ifDebugPrint("""
                         \(clubTestAmsterdam.fullNameTown): \
                         Completed insertSomeHardcodedMemberData() in background
                         """)
        } catch {
            ifDebugFatalError("Failed to save changes for Test Amsterdam",
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
