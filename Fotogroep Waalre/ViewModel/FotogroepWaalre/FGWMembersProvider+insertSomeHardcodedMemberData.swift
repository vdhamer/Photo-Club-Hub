//
//  FGWMembersProvider+insertSomeHardcodedMemberData.swift
//  FGWMembersProvider+insertSomeHardcodedMemberData
//
//  Created by Peter van den Hamer on 01/08/2021.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension FGWMembersProvider { // fill with some initial hard-coded content

    func insertSomeHardcodedMemberData(bgContext: NSManagedObjectContext, commit: Bool) {
        bgContext.performAndWait { // done asynchronously by CoreData (.perform also works)
            ifDebugPrint("Fotogroep Waalre: starting insertSomeHardcodedMemberData() in background")
            insertSomeHardcodedMemberDataCommon(bgContext: bgContext, commit: commit)
            ifDebugPrint("Fotogroep Waalre: completed insertSomeHardcodedMemberData() in background")
        }
    }

    private func insertSomeHardcodedMemberDataCommon(bgContext: NSManagedObjectContext, commit: Bool) {

        let clubWaalre = PhotoClub.findCreateUpdate( bgContext: bgContext,
                                                     photoClubIdPlus: FGWMembersProvider.photoClubWaalreIdPlus,
                                                     photoClubWebsite: URL(string: "https://www.fotogroepwaalre.nl"),
                                                     fotobondNumber: 1634, kvkNumber: 17261693,
                                                     coordinates: CLLocationCoordinate2D(latitude: 51.39184,
                                                                                         longitude: 5.46144),
                                                     priority: 1)
        clubWaalre.hasHardCodedMemberData = true // store in database that we ran insertSomeHardcodedMembers...

        addMember(context: bgContext,
                  givenName: "Bart", familyName: "van Stekelenburg", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: false ]))

        addMember(context: bgContext,
                  givenName: "Miek", familyName: "Kerkhoven", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: true ]))

        addMember(context: bgContext,
                  givenName: "Bettina", familyName: "de Graaf", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: false ]))

        addMember(context: bgContext,
                  givenName: "Erik", familyName: "van Geest", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true ]))

        addMember(context: bgContext,
                  givenName: "Greetje", familyName: "van Son", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: false ], stat: [:]))

        addMember(context: bgContext,
                  givenName: "Carel", familyName: "Bullens", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: true ], stat: [:]))

        addMember(context: bgContext,
                  givenName: "Jos", familyName: "Jansen", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .treasurer: true ]))

        addMember(context: bgContext,
                  givenName: "Marijke", familyName: "Gallas", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [:], stat: [ .honorary: true ]))

        addMember(context: bgContext,
                  givenName: "Peter", familyName: "van den Hamer", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: false, .secretary: false ]))

        addMember(context: bgContext,
                  givenName: "Kees", familyName: "van Gemert", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .secretary: true ]))

        addMember(context: bgContext,
                  givenName: "Bettina", familyName: "de Graaf", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus( stat: [ .former: true ])
        )

        if commit {
            do {
                if bgContext.hasChanges {
                    try bgContext.save() // commit all changes
                }
            } catch {
                ifDebugFatalError("Fotogroep Waalre: ERROR - failed to save changes to Core Data",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, the failed database inserts are only logged. App doesn't stop.
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
                           bgContext: context, givenName: givenName, familyName: familyName,
                           memberRolesAndStatus: memberRolesAndStatus,
                           bornDT: bornDT )

        _ = MemberPortfolio.findCreateUpdate(
                            context: context, photoClub: photoClub, photographer: photographer,
                            memberRolesAndStatus: memberRolesAndStatus,
                            memberWebsite: memberWebsite,
                            latestImage: latestImage)
    }
}
