//
//  TestClubRotterdamMembersProvider+insertSomeHardcodedMemberData.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 01/08/2021.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension TestClubRotterdamMembersProvider { // fill with some initial hard-coded content

    private static let testRotterdamURL = URL(string: "https://www.nederlandsfotomuseum.nl")
    static let photoClubTestRotterdamIdPlus = PhotoClubIdPlus(fullName: "Test Fotoclub",
                                                              town: "Rotterdam", // Amsterdam also has a "Test Fotoclub"
                                                              nickname: "FC Test Rdam")

    func insertSomeHardcodedMemberData(testRotterdamBackgroundContext: NSManagedObjectContext) {
        testRotterdamBackgroundContext.perform {
            ifDebugPrint("Photo Club Test Rdam: starting insertSomeHardcodedMemberData() in background")
            self.insertSomeHardcodedMemberDataCommon(testRotterdamBackgroundContext: testRotterdamBackgroundContext,
                                                     commit: true)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(testRotterdamBackgroundContext: NSManagedObjectContext,
                                                     commit: Bool) {

        // add photo club to Photo Clubs (if needed)
        let clubTestRotterdam = PhotoClub.findCreateUpdate(
                                             context: testRotterdamBackgroundContext,
                                             photoClubIdPlus: Self.photoClubTestRotterdamIdPlus,
                                             photoClubWebsite: TestClubRotterdamMembersProvider.testRotterdamURL,
                                             fotobondNumber: nil, kvkNumber: nil,
                                             coordinates: CLLocationCoordinate2D(latitude: 51.905292,
                                                                                 longitude: 4.486934),
                                             priority: 1
                                            )
        clubTestRotterdam.hasHardCodedMemberData = true // store in database that we ran insertSomeHardcodedMembers...

        addMember(context: testRotterdamBackgroundContext,
                  givenName: "Peter",
                  familyName: "van den Hamer",
                  photoClub: clubTestRotterdam,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true ], stat: [ .former: false]),
                  memberWebsite: URL(string: "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testR")!,
                  latestImage: URL(string:
                     "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testR/" +
		                                    "thumbs/2015_Madeira_RX1r_064.jpg")!,
                  phoneNumber: nil,
                  eMail: "foobar@vdhamer.com"
        )

        if commit {
            do {
                if testRotterdamBackgroundContext.hasChanges {
                    try testRotterdamBackgroundContext.save() // commit all changes
                }
                ifDebugPrint("Photo Club Test Rdam: completed insertSomeHardcodedMemberData()")
            } catch {
                fatalError("Failed to save changes for Test Rdam")
            }
        }

    }

    private func addMember(context: NSManagedObjectContext,
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
                            context: context, givenName: givenName, familyName: familyName,
                            memberRolesAndStatus: memberRolesAndStatus,
                            bornDT: bornDT )

        _ = MemberPortfolio.findCreateUpdate(
                            context: context, photoClub: photoClub, photographer: photographer,
                            memberRolesAndStatus: memberRolesAndStatus,
                            memberWebsite: memberWebsite,
                            latestImage: latestImage)
    }

}
