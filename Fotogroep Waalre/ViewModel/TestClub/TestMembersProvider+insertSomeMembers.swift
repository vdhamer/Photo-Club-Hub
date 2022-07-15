//
//  BIMembersProvider+insertSomeMembers.swift
//  BIMembersProvider+insertSomeMembers
//
//  Created by Peter van den Hamer on 01/08/2021.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension TestMembersProvider { // fill with some initial hard-coded content

    private static let testURL = URL(string: "https://www.nederlandsfotomuseum.nl")

    func insertSomeMembers(testBackgroundContext: NSManagedObjectContext) {
        testBackgroundContext.perform {
            print("Starting insertSomeMembers() for photo club Test in background")
            self.insertSomeMembersCommon(testBackgroundContext: testBackgroundContext, commit: true)
        }
    }

    private func insertSomeMembersCommon(testBackgroundContext: NSManagedObjectContext,
                                         commit: Bool) {

        // add photo club to Photo Clubs (if needed)
        let clubTest = PhotoClub.findCreateUpdate(
                                                         context: testBackgroundContext,
                                                         name: "Nederlands Fotografie Museum", town: "Rotterdam",
                                                         photoClubWebsite: TestMembersProvider.testURL,
                                                         fotobondNumber: 1234, kvkNumber: nil,
                                                         coordinates: CLLocationCoordinate2D(latitude: 51.905292,
                                                                                             longitude: 4.486934),
                                                         priority: 1
                                                        )

        // add Peter as a person to Photographers (if needed)
        let photographerPeter = Photographer.findCreateUpdate(
                                                             context: testBackgroundContext,
                                                             givenName: "Peter", familyName: "van den Hamer",
                                                             memberRolesAndStatus: MemberRolesAndStatus(role: [:],
                                                                                                        stat: [:]),
                                                             phoneNumber: nil, eMail: "foobar@vdhamer.com"
                                                            )
        // register Peter as a member of Test (if needed)
        _ = Member.findCreateUpdate(context: testBackgroundContext, // just a test case, no special roles
                                    photoClub: clubTest, photographer: photographerPeter,
                                    memberRolesAndStatus: MemberRolesAndStatus(role: [:], stat: [ .former: false]),
                                    memberWebsite: URL(string: "https://www.example.com/peter.html")
                                   )

        if commit {
            do {
                if testBackgroundContext.hasChanges {
                    try testBackgroundContext.save() // commit all changes
                }
                print("Completed insertSomeMembers() for Test in background")
            } catch {
                fatalError("Failed to save changes for Test")
            }
        }

    }

}
