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
            print("Starting insertSomeHardcodedMemberData() for Fotogroep Waalre in background")
            self.insertSomeHardcodedMemberDataCommon(fgwBackgroundContext: fgwBackgroundContext, commit: commit)
            print("Completed insertSomeHardcodedMemberData() for Fotogroep Waalre in background")
        }
    }

    // swiftlint:disable:next function_body_length
    private func insertSomeHardcodedMemberDataCommon(fgwBackgroundContext: NSManagedObjectContext, commit: Bool) {

        let clubWaalre = PhotoClub.findCreateUpdate( context: fgwBackgroundContext,
                                                     name: "Fotogroep Waalre", town: "Waalre",
                                                     photoClubWebsite: URL(string: "https://www.fotogroepwaalre.nl"),
                                                     fotobondNumber: 1634, kvkNumber: 17261693,
                                                     coordinates: CLLocationCoordinate2D(latitude: 51.39184,
                                                                                         longitude: 5.46144),
                                                     priority: 3)

        addMember(context: fgwBackgroundContext,
                  givenName: "Bart", familyName: "van Stekelenburg", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: true ]),
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/01/2022_FotogroepWaalre_010.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Bettina", familyName: "de Graaf", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: false ]),
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/01/2021_FotogroepWaalre_102.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Erik", familyName: "van Geest", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true ]),
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/07/2022_FotogroepWaalre_033.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Greetje", familyName: "van Son", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: true ], stat: [:]),
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/05/2022_FotogroepWaalre_035.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Jos", familyName: "Jansen", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .treasurer: true ]),
                  latestImage: URL(string:
                        "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/11/2022_ExpoFotogroepWaalre_011.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Marijke", familyName: "Gallas", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [:], stat: [ .honorary: true ]),
                  latestImage: URL(string:
                        "https://www.fotogroepwaalre.nl/fotos/Marijke_Gallas/images/2019_ExpoFotogroepWaalre_051.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Peter", familyName: "van den Hamer", photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true, .secretary: true ]),
                  memberWebsite: URL(string: "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer/")!,
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2021/09/2021_Iceland_R5_085.jpg")!
        )

        if commit {
            do {
                if fgwBackgroundContext.hasChanges {
                    try fgwBackgroundContext.save() // commit all changes
                }
            } catch {
                fatalError("Failed to save changes for Fotogroep Waalre")
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
