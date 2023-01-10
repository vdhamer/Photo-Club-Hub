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
    private static let photoClubBellusImagoID = PhotoClubID(id: (fullName: "Fotoclub Bellus Imago",
                                                                 town: "Veldhoven"),
                                                            shortNickname: "FC BellusImago")

    func insertSomeHardcodedMemberData(biBackgroundContext: NSManagedObjectContext) {
        let clubNickname = BIMembersProvider.photoClubBellusImagoID.shortNickname
        biBackgroundContext.perform {
            print("\(clubNickname): starting insertSomeHardcodedMemberData() in background")
            self.insertSomeHardcodedMemberDataCommon(biBackgroundContext: biBackgroundContext, commit: true)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(biBackgroundContext: NSManagedObjectContext,
                                                     commit: Bool) {

        // add Bellus Imago to Photo Clubs (if needed)
        let clubBellusImago = PhotoClub.findCreateUpdate(
                                                         context: biBackgroundContext,
                                                         photoClubID: Self.photoClubBellusImagoID,
                                                         photoClubWebsite: BIMembersProvider.bellusImagoURL,
                                                         fotobondNumber: 1671, kvkNumber: nil,
                                                         coordinates: CLLocationCoordinate2D(latitude: 51.425410,
                                                                                             longitude: 5.387560),
                                                         priority: 2
                                                        )

        addMember(context: biBackgroundContext, // add Rico to Photographers and member of Bellus (if needed)
                  givenName: "Rico",
                  familyName: "Coolen",
                  photoClub: clubBellusImago,
                  memberWebsite: URL(string: "https://www.fotoclubbellusimago.nl/rico.html")!,
                  latestImage: URL(string:
                     "https://www.fotoclubbellusimago.nl/uploads/5/5/1/2/55129719/vrijwerk-rico-3_orig.jpg"),
                  eMail: "info@ricoco.nl"
        )

        addMember(context: biBackgroundContext, // add Loek to Photographers and member of Bellus (if needed)
                  givenName: "Loek",
                  familyName: "Dirkx",
                  photoClub: clubBellusImago,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: true ]),
                  memberWebsite: URL(string: "https://www.fotoclubbellusimago.nl/loek.html")!,
                  latestImage: URL(string:
                     "https://www.fotoclubbellusimago.nl/uploads/5/5/1/2/55129719/vrijwerk-loek-1_2_orig.jpg")
        )

        if commit {
            let clubNickname = BIMembersProvider.photoClubBellusImagoID.shortNickname

            do {
                if biBackgroundContext.hasChanges {
                    try biBackgroundContext.save() // commit all changes
                }
                print("\(clubNickname): completed insertSomeHardcodedMemberData()")
            } catch {
                fatalError("\(clubNickname): ERROR - failed to save changes to Core Data")
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
