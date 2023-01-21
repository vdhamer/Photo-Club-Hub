//
//  TestClubMembersRProvider+insertSomeHardcodedMemberData.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 01/08/2021.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension TestClubRMembersProvider { // fill with some initial hard-coded content

    private static let testRURL = URL(string: "https://www.nederlandsfotomuseum.nl")
    static let photoClubTestRID = PhotoClubID(id: (fullName: "Test Fotoclub", // identical name to club in Amsterdam
                                                  town: "Rotterdam"),
                                             shortNickname: "FC Test Rdam")

    func insertSomeHardcodedMemberData(testRBackgroundContext: NSManagedObjectContext) {
        testRBackgroundContext.perform {
            print("Photo Club Test Rdam: starting insertSomeHardcodedMemberData() in background")
            self.insertSomeHardcodedMemberDataCommon(testRBackgroundContext: testRBackgroundContext, commit: true)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(testRBackgroundContext: NSManagedObjectContext,
                                                     commit: Bool) {

        // add photo club to Photo Clubs (if needed)
        let clubTestR = PhotoClub.findCreateUpdate(
                                                         context: testRBackgroundContext,
                                                         photoClubID: Self.photoClubTestRID,
                                                         photoClubWebsite: TestClubRMembersProvider.testRURL,
                                                         fotobondNumber: 1234, kvkNumber: nil,
                                                         coordinates: CLLocationCoordinate2D(latitude: 51.905292,
                                                                                             longitude: 4.486934),
                                                         priority: 1
                                                        )

        addMember(context: testRBackgroundContext,
                  givenName: "Peter",
                  familyName: "van den Hamer",
                  photoClub: clubTestR,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true ], stat: [ .former: false]),
                  memberWebsite: URL(string: "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testR")!,
                  latestImage: URL(string:
                     "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testR/" +
		                                    "images/2015_Madeira_RX1r_064.jpg")!,
                  phoneNumber: nil,
                  eMail: "foobar@vdhamer.com"
        )

        if commit {
            do {
                if testRBackgroundContext.hasChanges {
                    try testRBackgroundContext.save() // commit all changes
                }
                print("Photo Club Test Rdam: completed insertSomeHardcodedMemberData()")
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
