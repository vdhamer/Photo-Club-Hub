//
//  TestClubAmsterdamMembersProvider+insertSomeHardcodedMemberData.swift
//  Fotogroep Waalre
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

    func insertSomeHardcodedMemberData(testAmsterdamBackgroundContext: NSManagedObjectContext) {
        testAmsterdamBackgroundContext.perform {
            print("Photo Club Test Adam: starting insertSomeHardcodedMemberData() in background")
            self.insertSomeHardcodedMemberDataCommon(testAmsterdamBackgroundContext: testAmsterdamBackgroundContext,
                                                     commit: true)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(testAmsterdamBackgroundContext: NSManagedObjectContext,
                                                     commit: Bool) {

        // add photo club to Photo Clubs (if needed)
        let clubTestAmsterdam = PhotoClub.findCreateUpdate(
                                                 context: testAmsterdamBackgroundContext,
                                                 photoClubIdPlus: Self.photoClubTestAmsterdamIdPlus,
                                                 photoClubWebsite: TestClubAmsterdamMembersProvider.testAmsterdamURL,
                                                 fotobondNumber: 5678, kvkNumber: nil,
                                                 coordinates: CLLocationCoordinate2D(latitude: 52.364217,
                                                                                     longitude: 4.893370),
                                                 priority: 1
                                                )

        addMember(context: testAmsterdamBackgroundContext,
                  givenName: "Peter",
                  familyName: "van den Hamer",
                  photoClub: clubTestAmsterdam,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .secretary: true ], stat: [ .former: false]),
                  memberWebsite: URL(string: "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testA")!,
                  latestImage: URL(string:
                     "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testA/" +
                                                    "thumbs/2022_Iceland_R5_013.jpg")!,
//                  phoneNumber: nil,
                  eMail: "foobarA@vdhamer.com"
        )

        if commit {
            do {
                if testAmsterdamBackgroundContext.hasChanges { // is this necessary? sometimes save() done earlier
                    try testAmsterdamBackgroundContext.save() // commit all changes
                }
                print("Photo Club TestAmsterdam: completed insertSomeHardcodedMemberData()")
            } catch {
                fatalError("Failed to save changes for TestAmsterdam")
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
