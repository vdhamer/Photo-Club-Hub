//
//  BIMembersProvider+insertSomeHardcodedMemberData.swift
//  BIMembersProvider+insertSomeHardcodedMemberData
//
//  Created by Peter van den Hamer on 01/08/2021.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension BIMembersProvider { // fill with some initial hard-coded content

    private static let bellusImagoURL = URL(string: "https://www.fotoClubBellusImago.nl")

    func insertSomeHardcodedMemberData(biBackgroundContext: NSManagedObjectContext) {
        biBackgroundContext.perform {
            print("Bellus Imago: starting insertSomeHardcodedMemberData() in background")
            self.insertSomeHardcodedMemberDataCommon(biBackgroundContext: biBackgroundContext, commit: true)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(biBackgroundContext: NSManagedObjectContext,
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
                                                             phoneNumber: "", eMail: "info@ricoco.nl"
                                                            )
        // register Rico a member of Bellus Imago (if needed)
        _ = MemberPortfolio.findCreateUpdate(context: biBackgroundContext, // just a test case, no special roles
                                    photoClub: clubBellusImago, photographer: photographerRico,
                                    memberRolesAndStatus: MemberRolesAndStatus(role: [:], stat: [ .former: false]),
                                    memberWebsite: URL(string: "https://www.fotoclubbellusimago.nl/rico.html")
                                   )

        // add Loek as a person to Photographers (if needed)
        let photographerLoek = Photographer.findCreateUpdate(
                                                             context: biBackgroundContext,
                                                             givenName: "Loek", familyName: "Dirkx"
                                                            )
        // register Loek a member of Bellus Imago (if needed)
        _ = MemberPortfolio.findCreateUpdate(context: biBackgroundContext, // just a test case, no special roles
                                    photoClub: clubBellusImago, photographer: photographerLoek,
                                    memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: true ], stat: [:]),
                                    memberWebsite: URL(string: "https://www.fotoclubbellusimago.nl/loek.html")
                                   )

        if commit {
            do {
                if biBackgroundContext.hasChanges {
                    try biBackgroundContext.save() // commit all changes
                }
                print("Bellus Imago: completed insertSomeHardcodedMemberData()")
            } catch {
                fatalError("Bellus Imago: ERROR - failed to save changes to Core Data")
            }
        }

    }

}
