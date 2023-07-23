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
            ifDebugPrint("""
                         \(Self.photoClubTestRotterdamIdPlus.fullNameCommaTown): \
                         starting insertSomeHardcodedMemberData() in background
                         """)
            self.insertSomeHardcodedMemberDataCommon(bgContext: bgContext, commit: true)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(bgContext: NSManagedObjectContext, commit: Bool) {

        // add photo club to Photo Clubs (if needed)
        let clubTestRotterdam = PhotoClub.findCreateUpdate(
                                             bgContext: bgContext,
                                             photoClubIdPlus: Self.photoClubTestRotterdamIdPlus,
                                             photoClubWebsite: TestClubRotterdamMembersProvider.testRotterdamURL,
                                             fotobondNumber: nil, kvkNumber: nil,
                                             coordinates: CLLocationCoordinate2D(latitude: 51.905292,
                                                                                 longitude: 4.486934),
                                             priority: 1
                                            )
        clubTestRotterdam.hasHardCodedMemberData = true // store in database that we ran insertSomeHardcodedMembers...

        addMember(bgContext: bgContext,
                  givenName: "Peter",
                  familyName: "van den Hamer",
                  photoClub: clubTestRotterdam,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true ], stat: [ .former: false]),
                  memberWebsite: URL(string: "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testR")!,
                  latestImage: URL(string:
                     "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testR/" +
		                                    "thumbs/2015_Madeira_RX1r_064.jpg")!,
                  phoneNumber: nil,
                  eMail: "foobarR@vdhamer.com"
        )

        if commit {
            do {
                if bgContext.hasChanges {
                    try bgContext.save() // commit all changes
                }
                ifDebugPrint("""
                             \(Self.photoClubTestRotterdamIdPlus.fullNameCommaTown): \
                             completed insertSomeHardcodedMemberData()
                             """)
            } catch {
                ifDebugFatalError("Failed to save changes for Test Rotterdam",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, failing to store the data is only logged. And the app doesn't stop.
            }
        }

    }

    private func addMember(bgContext: NSManagedObjectContext,
                           givenName: String,
                           familyName: String,
                           bornDT: Date? = nil,
                           photoClub: PhotoClub,
                           memberRolesAndStatus: MemberRolesAndStatus = MemberRolesAndStatus(role: [:], stat: [:]),
                           memberWebsite: URL? = nil,
                           latestImage: URL? = nil,
                           phoneNumber: String? = nil,
                           eMail: String? = nil) {
        let photographer = Photographer.findCreateUpdate(
                            bgContext: bgContext, givenName: givenName, familyName: familyName, // TODO - check MOC
                            memberRolesAndStatus: memberRolesAndStatus,
                            bornDT: bornDT )

        _ = MemberPortfolio.findCreateUpdate(
                            bgContext: bgContext, photoClub: photoClub, photographer: photographer,
                            memberRolesAndStatus: memberRolesAndStatus,
                            memberWebsite: memberWebsite,
                            latestImage: latestImage)
    }

}
