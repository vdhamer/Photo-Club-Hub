//
//  FGWMembersProvider+insertSomeMembers.swift
//  FGWMembersProvider+insertSomeMembers
//
//  Created by Peter van den Hamer on 01/08/2021.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension FGWMembersProvider { // fill with some initial hard-coded content

    func insertSomeMembers(fgwBackgroundContext: NSManagedObjectContext, commit: Bool) {
        print("Starting insertSomeMembers() for Fotogroep Waalre in background")
        fgwBackgroundContext.perform {
            self.insertSomeMembersCommon(fgwBackgroundContext: fgwBackgroundContext, commit: commit)
        }
    }

    private func insertSomeMembersCommon(fgwBackgroundContext: NSManagedObjectContext, commit: Bool) {

        let clubWaalre = PhotoClub.findCreateUpdate( context: fgwBackgroundContext,
                                                     name: "Fotogroep Waalre", town: "Waalre",
                                                     photoClubWebsite: URL(string: "https://www.fotogroepwaalre.nl"),
                                                     fotobondNumber: 1634, kvkNumber: 17261693,
                                                     coordinates: CLLocationCoordinate2D(latitude: 51.39184,
                                                                                         longitude: 5.46144),
                                                     priority: 3)

        addMember(context: fgwBackgroundContext,
                  givenName: "Peter", familyName: "van den Hamer", bornDT: toDate(from: "18/10/1957"),
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true, .secretary: true ], stat: [:]),
                  memberWebsite: URL(string: "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer/")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Bart", familyName: "van Stekelenburg", bornDT: toDate(from: "2/6/1970"),
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: true ], stat: [:])
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Greetje", familyName: "van Son", bornDT: toDate(from: "27/11/1950"),
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: true ], stat: [:])
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Jos", familyName: "Jansen", bornDT: toDate(from: "17/5/1945"),
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .treasurer: true ], stat: [:])
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Marijke", familyName: "Gallas", bornDT: toDate(from: "16/7/1937"),
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [:], stat: [ .honorary: true ])
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Erik", familyName: "van Geest", bornDT: toDate(from: "16/09/1967"),
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true ], stat: [:])
        )

        if commit {
            do {
                if fgwBackgroundContext.hasChanges {
                    try fgwBackgroundContext.save() // commit all changes
                }
                print("Completed insertSomeMembers() for Fotogroep Waalre in background")
            } catch {
                fatalError("Failed to save changes for Fotogroep Waalre")
            }
        }

    }

    private func toDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.date(from: dateString)
    }

    private func addMember(context: NSManagedObjectContext,
                           givenName: String,
                           familyName: String,
                           bornDT: Date? = nil,
                           photoClub: PhotoClub,
                           memberRolesAndStatus: MemberRolesAndStatus,
                           memberWebsite: URL? = nil) {
        let photographer = Photographer.findCreateUpdate(
                            context: context, givenName: givenName, familyName: familyName,
                            memberRolesAndStatus: memberRolesAndStatus,
                            bornDT: bornDT )

        _ = Member.findCreateUpdate(
                            context: context, photoClub: photoClub, photographer: photographer,
                            memberRolesAndStatus: memberRolesAndStatus,
                            memberWebsite: memberWebsite)
    }
}
