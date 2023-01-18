//
//  FGWMembersProvider+insertSomeHardcodedMemberData.swift
//  FGWMembersProvider+insertSomeHardcodedMemberData
//
//  Created by Peter van den Hamer on 01/08/2021.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension FGWMembersProvider { // fill with some initial hard-coded content

    func insertSomeHardcodedMemberData(fgwBackgroundContext: NSManagedObjectContext, commit: Bool) {
        fgwBackgroundContext.performAndWait { // done asynchronously by CoreData (.perform also works)
            print("Fotogroep Waalre: starting insertSomeHardcodedMemberData() in background")
            insertSomeHardcodedMemberDataCommon(fgwBackgroundContext: fgwBackgroundContext, commit: commit)
            print("Fotogroep Waalre: completed insertSomeHardcodedMemberData()")
        }
    }

    private func insertSomeHardcodedMemberDataCommon(fgwBackgroundContext: NSManagedObjectContext, commit: Bool) {

        let clubWaalre = PhotoClub.findCreateUpdate( context: fgwBackgroundContext,
                                                     photoClubID: FGWMembersProvider.photoClubWaalreID,
                                                     photoClubWebsite: URL(string: "https://www.fotogroepwaalre.nl"),
                                                     fotobondNumber: 1634, kvkNumber: 17261693,
                                                     coordinates: CLLocationCoordinate2D(latitude: 51.39184,
                                                                                         longitude: 5.46144),
                                                     priority: 3)

        addMember(context: fgwBackgroundContext,
                  givenName: "Bart", familyName: "van Stekelenburg", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: false ])
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Miek", familyName: "Kerkhoven", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: true ])
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Bettina", familyName: "de Graaf", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: false ])
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Erik", familyName: "van Geest", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true ])
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Greetje", familyName: "van Son", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: false ], stat: [:])
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Carel", familyName: "Bullens", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: true ], stat: [:])
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Jos", familyName: "Jansen", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .treasurer: true ])
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Marijke", familyName: "Gallas", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [:], stat: [ .honorary: true ])
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Peter", familyName: "van den Hamer", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: false, .secretary: false ])
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Kees", familyName: "van Gemert", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .secretary: true ])
        )

        if commit {
            do {
                if fgwBackgroundContext.hasChanges {
                    try fgwBackgroundContext.save() // commit all changes
                }
            } catch {
                fatalError("Fotogroep Waalre: ERROR - failed to save changes to Core Data")
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
                           latestImage: URL? = nil) {
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
