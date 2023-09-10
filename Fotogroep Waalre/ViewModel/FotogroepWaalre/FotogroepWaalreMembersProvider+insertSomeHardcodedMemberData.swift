//
//  FotogroepWaalreMembersProvider+insertSomeHardcodedMemberData.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 01/08/2021.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension FotogroepWaalreMembersProvider { // fill with some initial hard-coded content

    func insertSomeHardcodedMemberData(bgContext: NSManagedObjectContext) { // runs on a background thread
        ifDebugPrint("""
                     \(Self.photoClubWaalreIdPlus.fullNameTown): \
                     Starting insertSomeHardcodedMemberData() in background
                     """)

        let clubWaalre = PhotoClub.findCreateUpdate(
                                        context: bgContext,
                                        photoClubIdPlus: FotogroepWaalreMembersProvider.photoClubWaalreIdPlus,
                                        photoClubWebsite: URL(string: "https://www.fotogroepwaalre.nl"),
                                        fotobondNumber: 1634, kvkNumber: 17261693,
                                        coordinates: CLLocationCoordinate2D(latitude: 51.39184, longitude: 5.46144)
                                        )
        clubWaalre.hasHardCodedMemberData = true // store in database that we ran insertSomeHardcodedMembers...

        addMember(bgContext: bgContext, givenName: "Bart", infixName: "van", familyName: "Stekelenburg",
                  photoClub: clubWaalre, memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: false ]))

        addMember(bgContext: bgContext, givenName: "Bettina", infixName: "de", familyName: "Graaf",
                  photoClub: clubWaalre, memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: false ],
                                                             stat: [.former: true]))

        addMember(bgContext: bgContext, givenName: "Carel", infixName: "", familyName: "Bullens",
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: true ], stat: [:]))

        addMember(bgContext: bgContext, givenName: "Erik", infixName: "van", familyName: "Geest",
                  photoClub: clubWaalre, memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true ]))

        addMember(bgContext: bgContext, givenName: "Greetje", infixName: "van", familyName: "Son",
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: false ], stat: [:]))

        addMember(bgContext: bgContext, givenName: "Henriëtte", infixName: "van", familyName: "Ekert",
                  photoClub: clubWaalre, memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true ]))

        addMember(bgContext: bgContext, givenName: "Jos", infixName: "", familyName: "Jansen",
                  photoClub: clubWaalre, memberRolesAndStatus: MemberRolesAndStatus(role: [ .treasurer: true ]))

        addMember(bgContext: bgContext, givenName: "Kees", infixName: "van", familyName: "Gemert",
                  photoClub: clubWaalre, memberRolesAndStatus: MemberRolesAndStatus(role: [ .secretary: true ]))

        addMember(bgContext: bgContext, givenName: "Marijke", infixName: "", familyName: "Gallas",
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [:], stat: [ .honorary: true ]))

        addMember(bgContext: bgContext, givenName: "Miek", infixName: "", familyName: "Kerkhoven",
                  photoClub: clubWaalre, memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: true ]))

        addMember(bgContext: bgContext, givenName: "Peter", infixName: "van den", familyName: "Hamer",
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: false, .secretary: false ],
                                                             stat: [.former: true]))
        do {
//            if bgContext.hasChanges { // optimization
                try bgContext.save() // commit all changes
//            }
            ifDebugPrint("""
                         \(Self.photoClubWaalreIdPlus.fullNameTown): \
                         Completed insertSomeHardcodedMemberData() in background
                         """)
        } catch {
            ifDebugFatalError("Fotogroep Waalre: ERROR - failed to save changes to Core Data",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, the failed database inserts are only logged. App doesn't stop.
        }

    }

    private func addMember(bgContext: NSManagedObjectContext,
                           givenName: String,
                           infixName: String,
                           familyName: String,
                           bornDT: Date? = nil,
                           photoClub: PhotoClub,
                           memberRolesAndStatus: MemberRolesAndStatus = MemberRolesAndStatus(role: [:], stat: [:]),
                           memberWebsite: URL? = nil,
                           latestImage: URL? = nil) {
        let photographer = Photographer.findCreateUpdate(
                           context: bgContext,
                           givenName: givenName, infixName: infixName, familyName: familyName,
                           memberRolesAndStatus: memberRolesAndStatus,
                           bornDT: bornDT,
                           photoClub: photoClub)

        _ = MemberPortfolio.findCreateUpdate(
                            bgContext: bgContext, photoClub: photoClub, photographer: photographer,
                            memberRolesAndStatus: memberRolesAndStatus,
                            memberWebsite: memberWebsite,
                            latestImage: latestImage)
        // do not need to bgContext.save() because a series of added members will be saved simultaneously
    }
}