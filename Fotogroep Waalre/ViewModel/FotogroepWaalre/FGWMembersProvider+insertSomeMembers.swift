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
            print("Completed insertSomeMembers() for Fotogroep Waalre in background")
        }
    }

    // swiftlint:disable:next function_body_length
    private func insertSomeMembersCommon(fgwBackgroundContext: NSManagedObjectContext, commit: Bool) {

        let clubWaalre = PhotoClub.findCreateUpdate( context: fgwBackgroundContext,
                                                     name: "Fotogroep Waalre", town: "Waalre",
                                                     photoClubWebsite: URL(string: "https://www.fotogroepwaalre.nl"),
                                                     fotobondNumber: 1634, kvkNumber: 17261693,
                                                     coordinates: CLLocationCoordinate2D(latitude: 51.39184,
                                                                                         longitude: 5.46144),
                                                     priority: 3)

        addMember(context: fgwBackgroundContext,
                  givenName: "Bart", familyName: "van Stekelenburg", bornDT: toDate(from: "2/6/1970"),
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: true ], stat: [:]),
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/07/2022_FotogroepWaalre_057.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Bettina", familyName: "de Graaf", bornDT: toDate(from: "19/07/1970"),
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: true ], stat: [:]),
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/05/2022_FotogroepWaalre_019.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Bram", familyName: "van den Berge", bornDT: toDate(from: "28/04/1952"),
                  photoClub: clubWaalre,
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2021/04/2021_FotogroepWaalre_005.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Carel", familyName: "Bullens", bornDT: toDate(from: "01/11/1952"),
                  photoClub: clubWaalre,
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/05/2022_FotogroepWaalre_021.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Cassandra", familyName: "Postema", bornDT: toDate(from: "28/01/1971"),
                  photoClub: clubWaalre,
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/05/2022_FotogroepWaalre_022.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Conny", familyName: "Klessens", bornDT: toDate(from: "05/12/1964"),
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true ], stat: [:]),
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/07/2022_FotogroepWaalre_049.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Erik", familyName: "van Geest", bornDT: toDate(from: "16/09/1967"),
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true ], stat: [:]),
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/07/2022_FotogroepWaalre_033.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "François", familyName: "Hermans", bornDT: toDate(from: "10/08/1956"),
                  photoClub: clubWaalre,
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2011/02/varen-2.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Greetje", familyName: "van Son", bornDT: toDate(from: "27/11/1950"),
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: false ], stat: [:]),
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/08/2022_FotogroepWaalre_079.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Guus", familyName: "Maas", bornDT: toDate(from: "22/06/1946"),
                  photoClub: clubWaalre,
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/07/2022_FotogroepWaalre_059.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Henny", familyName: "Looren de Jong", bornDT: toDate(from: "28/05/1946"),
                  photoClub: clubWaalre,
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/08/2022_FotogroepWaalre_080.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Henriëtte", familyName: "van Ekert", bornDT: toDate(from: "21/11/1957"),
                  photoClub: clubWaalre,
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/07/2022_FotogroepWaalre_055.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Jos", familyName: "Jansen", bornDT: toDate(from: "17/5/1945"),
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .treasurer: true ], stat: [:]),
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/08/2022_FotogroepWaalre_081.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Kees", familyName: "van Gemert", bornDT: toDate(from: "05/06/1953"),
                  photoClub: clubWaalre,
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2021/04/2021_FotogroepWaalre_024.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Marijke", familyName: "Gallas", bornDT: toDate(from: "16/7/1937"),
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [:], stat: [ .honorary: true ]),
                  latestImage: URL(string:
                        "https://www.fotogroepwaalre.nl/fotos/Marijke_Gallas/images/2019_ExpoFotogroepWaalre_051.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Miek", familyName: "Kerkhoven", bornDT: toDate(from: "09/02/1951"),
                  photoClub: clubWaalre,
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/07/2022_FotogroepWaalre_067.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Peter", familyName: "van den Hamer", bornDT: toDate(from: "18/10/1957"),
                  photoClub: clubWaalre,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true, .secretary: true ], stat: [:]),
                  memberWebsite: URL(string: "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer/")!,
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/08/2013_Phoenix_RX1r_580.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Sipke", familyName: "Wadman", bornDT: toDate(from: "18/09/1951"),
                  photoClub: clubWaalre,
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2021/09/2021_FotogroepWaalre_045.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Tis", familyName: "Veugen", bornDT: toDate(from: "30/04/1957"),
                  photoClub: clubWaalre,
                  latestImage: URL(string:
                            "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/07/2022_FotogroepWaalre_052.jpg")!
        )

        addMember(context: fgwBackgroundContext,
                  givenName: "Zoë", familyName: "Aspirant",
                  photoClub: clubWaalre
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
