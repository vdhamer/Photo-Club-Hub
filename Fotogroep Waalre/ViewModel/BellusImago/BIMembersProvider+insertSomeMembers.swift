//
//  BIMembersProvider+insertSomeMembers.swift
//  BIMembersProvider+insertSomeMembers
//
//  Created by Peter van den Hamer on 01/08/2021.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension BIMembersProvider { // fill with some initial hard-coded content

    private static let bellusImagoURL = URL(string: "https://www.fotoClubBellusImago.nl")

    func insertSomeMembers(biBackgroundContext: NSManagedObjectContext) {
        biBackgroundContext.perform {
            print("Starting insertSomeMembers() for Bellus Imago in background")
            self.insertSomeMembersCommon(biBackgroundContext: biBackgroundContext, commit: true)
        }
    }

    private func insertSomeMembersCommon(biBackgroundContext: NSManagedObjectContext,
                                         commit: Bool) {

        // add Bellus Imago to Photo Clubs (if needed)
        let clubBellusImago = PhotoClub.findCreateUpdate(
                                                         context: biBackgroundContext,
                                                         name: "Bellus Imago", town: "Veldhoven",
                                                         photoClubWebsite: BIMembersProvider.bellusImagoURL,
                                                         fotobondNumber: 1671, kvkNumber: nil,
                                                         coordinates: CLLocationCoordinate2D(latitude: 51.425410,
                                                                                             longitude: 5.387560),
                                                         priority: 2
                                                        )

        // add Rico as a person to Photographers (if needed)
        let photographerRico = Photographer.findCreateUpdate(
                                                             context: biBackgroundContext,
                                                             givenName: "Rico", familyName: "Coolen",
                                                             memberRolesAndStatus: MemberRolesAndStatus(role: [:],
                                                                                                        stat: [:]),
                                                             phoneNumber: "", eMail: "info@ricoco.nl"
                                                            )
        // register Rico a member of Bellus Imago (if needed)
        _ = Member.findCreateUpdate(context: biBackgroundContext, // just a test case, no special roles
                                    photoClub: clubBellusImago, photographer: photographerRico,
                                    memberRolesAndStatus: MemberRolesAndStatus(role: [:], stat: [ .former: false]),
                                    memberWebsite: URL(string: "https://www.fotoclubbellusimago.nl/rico.html")
                                   )

        // add Loek as a person to Photographers (if needed)
        let photographerLoek = Photographer.findCreateUpdate(
                                                             context: biBackgroundContext,
                                                             givenName: "Loek", familyName: "Dirkx",
                                                             memberRolesAndStatus: MemberRolesAndStatus(role: [:],
                                                                                                        stat: [:])
                                                            )
        // register Loek a member of Bellus Imago (if needed)
        _ = Member.findCreateUpdate(context: biBackgroundContext, // just a test case, no special roles
                                    photoClub: clubBellusImago, photographer: photographerLoek,
                                    memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: true ], stat: [:]),
                                    memberWebsite: URL(string: "https://www.fotoclubbellusimago.nl/loek.html")
                                   )

        if commit {
            do {
                if biBackgroundContext.hasChanges {
                    try biBackgroundContext.save() // commit all changes
                }
                print("Completed insertSomeMembers() for Bellus Imago in background")
            } catch {
                fatalError("Failed to save changes for Bellus Imago")
            }
        }

    }

}
