//
//  TestClubDenHaagMembersProvider+insertSomeHardcodedMemberData.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 11/01/2023.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension TestClubDenHaagMembersProvider { // fill with some initial hard-coded content

    private static let testDenHaagURL = URL(string: "https://www.km21.nl")
    static let photoClubTestDenHaagIdPlus = PhotoClubIdPlus(fullName: "Test Fotoclub",
                                                              town: "Den Haag", // Rotterdam also has a "Test Fotoclub"
                                                              nickname: "FC Test DenHaag")

    func insertSomeHardcodedMemberData(testDenHaagBackgroundContext: NSManagedObjectContext) {
        testDenHaagBackgroundContext.perform {
            ifDebugPrint("Photo Club Test Adam: starting insertSomeHardcodedMemberData() in background")
            self.insertSomeHardcodedMemberDataCommon(testDenHaagBackgroundContext: testDenHaagBackgroundContext,
                                                     commit: true)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(testDenHaagBackgroundContext: NSManagedObjectContext,
                                                     commit: Bool) {

        // add photo club to Photo Clubs (if needed)
        let clubTestDenHaag = PhotoClub.findCreateUpdate(
                                                 context: testDenHaagBackgroundContext,
                                                 photoClubIdPlus: Self.photoClubTestDenHaagIdPlus,
                                                 photoClubWebsite: TestClubDenHaagMembersProvider.testDenHaagURL,
                                                 fotobondNumber: nil, kvkNumber: nil,
                                                 coordinates: CLLocationCoordinate2D(latitude: 52.090556,
                                                                                     longitude: 4.279722),
                                                 priority: 1
                                                )
        clubTestDenHaag.hasHardCodedMemberData = true // store in database that we ran insertSomeHardcodedMembers...

        addMember(context: testDenHaagBackgroundContext,
                  givenName: "Peter",
                  familyName: "van den Hamer",
                  photoClub: clubTestDenHaag,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: true ], stat: [ .former: false]),
                  memberWebsite: URL(string: "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testDH")!,
                  latestImage: URL(string:
                     "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testDH/" +
                                                    "thumbs/2010_Barcelona_95.jpg")!,
                  eMail: "foobarDH@vdhamer.com"
        )

        if commit {
            do {
                if testDenHaagBackgroundContext.hasChanges { // is this necessary? sometimes save() done earlier
                    try testDenHaagBackgroundContext.save() // commit all changes
                }
                ifDebugPrint("Photo Club TestDenHaag: completed insertSomeHardcodedMemberData()")
            } catch {
                fatalError("Failed to save changes for TestDenHaag")
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
