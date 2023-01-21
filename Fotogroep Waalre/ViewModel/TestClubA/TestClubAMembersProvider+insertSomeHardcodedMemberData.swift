//
//  TestClubAMembersProvider+insertSomeHardcodedMemberData.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 11/01/2023.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension TestClubAMembersProvider { // fill with some initial hard-coded content

    private static let testAURL = URL(string: "https://www.foam.org")
    static let photoClubTestAID = PhotoClubID(id: (fullName: "Test Fotoclub", // identical name to club in Rotterdam
                                                   town: "Amsterdam"),
                                              shortNickname: "FC Test Adam")

    func insertSomeHardcodedMemberData(testABackgroundContext: NSManagedObjectContext) {
        testABackgroundContext.perform {
            print("Photo Club Test Adam: starting insertSomeHardcodedMemberData() in background")
            self.insertSomeHardcodedMemberDataCommon(testABackgroundContext: testABackgroundContext, commit: true)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(testABackgroundContext: NSManagedObjectContext,
                                                     commit: Bool) {

        // add photo club to Photo Clubs (if needed)
        let clubTestA = PhotoClub.findCreateUpdate(
                                                         context: testABackgroundContext,
                                                         photoClubID: Self.photoClubTestAID,
                                                         photoClubWebsite: TestClubAMembersProvider.testAURL,
                                                         fotobondNumber: 5678, kvkNumber: nil,
                                                         coordinates: CLLocationCoordinate2D(latitude: 52.364217,
                                                                                             longitude: 4.893370),
                                                         priority: 1
                                                        )

        addMember(context: testABackgroundContext,
                  givenName: "Peter",
                  familyName: "van den Hamer",
                  photoClub: clubTestA,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .secretary: true ], stat: [ .former: false]),
                  memberWebsite: URL(string: "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testA")!,
                  latestImage: URL(string:
                     "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testA/" +
                                                    "images/2022_Iceland_R5_013.jpg")!,
//                  phoneNumber: nil,
                  eMail: "foobarA@vdhamer.com"
        )

        if commit {
            do {
                if testABackgroundContext.hasChanges { // TODO: does this give problems?
                    try testABackgroundContext.save() // commit all changes
                }
                print("Photo Club TestA: completed insertSomeHardcodedMemberData()")
            } catch {
                fatalError("Failed to save changes for TestA")
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
