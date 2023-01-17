//
//  TestClub2MembersProvider+insertSomeHardcodedMemberData.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 11/01/2023.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension TestClub2MembersProvider { // fill with some initial hard-coded content

    private static let test2URL = URL(string: "https://www.foam.org")
    static let photoClubTest2ID = PhotoClubID(id: (fullName: "Test Fotoclub", // identical name to club in Rotterdam
                                                   town: "Amsterdam"),
                                             shortNickname: "FC Test2")

    func insertSomeHardcodedMemberData(test2BackgroundContext: NSManagedObjectContext) {
        test2BackgroundContext.perform {
            print("Photo Club Test2: starting insertSomeHardcodedMemberData() in background")
            self.insertSomeHardcodedMemberDataCommon(test2BackgroundContext: test2BackgroundContext, commit: true)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(test2BackgroundContext: NSManagedObjectContext,
                                                     commit: Bool) {

        // add photo club to Photo Clubs (if needed)
        let clubTest2 = PhotoClub.findCreateUpdate(
                                                         context: test2BackgroundContext,
                                                         photoClubID: Self.photoClubTest2ID,
                                                         photoClubWebsite: TestClub2MembersProvider.test2URL,
                                                         fotobondNumber: 5678, kvkNumber: nil,
                                                         coordinates: CLLocationCoordinate2D(latitude: 52.364217,
                                                                                             longitude: 4.893370),
                                                         priority: 1
                                                        )

        addMember(context: test2BackgroundContext,
                  givenName: "Peter",
                  familyName: "van den Hamer",
                  photoClub: clubTest2,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: true ]),
                  memberWebsite: URL(string: "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_test2")!,
                  latestImage: URL(string:
                     "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_test2/" +
                                                    "images/2015_Madeira_RX1r_064.jpg")!,
                  phoneNumber: nil,
                  eMail: "foobar2@vdhamer.com"
        )

        if commit {
            do {
                if test2BackgroundContext.hasChanges {
                    try test2BackgroundContext.save() // commit all changes
                }
                print("Photo Club Test2: completed insertSomeHardcodedMemberData()")
            } catch {
                fatalError("Failed to save changes for Test2")
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
