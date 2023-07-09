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
    private static let photoClubBellusImagoIdPlus = PhotoClubIdPlus(fullName: "Fotoclub Bellus Imago",
                                                                    town: "Veldhoven",
                                                                    nickname: "FC BellusImago")

    func insertSomeHardcodedMemberData(bgContext: NSManagedObjectContext) {
        let clubNickname = BIMembersProvider.photoClubBellusImagoIdPlus.nickname
        bgContext.perform {
            ifDebugPrint("\(clubNickname): starting insertSomeHardcodedMemberData() in background")
            self.insertSomeHardcodedMemberDataCommon(bgContext: bgContext, commit: true)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(bgContext: NSManagedObjectContext, commit: Bool) {

        // add Bellus Imago to Photo Clubs (if needed)
        let clubBellusImago = PhotoClub.findCreateUpdate(
                                                         bgContext: bgContext,
                                                         photoClubIdPlus: Self.photoClubBellusImagoIdPlus,
                                                         photoClubWebsite: BIMembersProvider.bellusImagoURL,
                                                         fotobondNumber: 1671, kvkNumber: nil,
                                                         coordinates: CLLocationCoordinate2D(latitude: 51.425410,
                                                                                             longitude: 5.387560),
                                                         priority: 2
                                                        )
        clubBellusImago.hasHardCodedMemberData = true // store in database that we ran insertSomeHardcodedMembers...

        addMember(bgContext: bgContext, // add Rico to Photographers and member of Bellus (if needed)
                  givenName: "Rico",
                  familyName: "Coolen",
                  photographerWebsite: URL(string: "https://www.ricoco.nl"),
                  photoClub: clubBellusImago,
                  memberWebsite: URL(string: "https://www.fotoclubbellusimago.nl/rico.html")!,
                  latestImage: URL(string:
                     "https://www.fotoclubbellusimago.nl/uploads/5/5/1/2/55129719/vrijwerk-rico-3_orig.jpg"),
                  eMail: "info@ricoco.nl"
        )

        addMember(bgContext: bgContext, // add Loek to Photographers and member of Bellus (if needed)
                  givenName: "Loek",
                  familyName: "Dirkx",
                  photoClub: clubBellusImago,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: true ]),
                  memberWebsite: URL(string: "https://www.fotoclubbellusimago.nl/loek.html")!,
                  latestImage: URL(string:
                     "https://www.fotoclubbellusimago.nl/uploads/5/5/1/2/55129719/vrijwerk-loek-1_2_orig.jpg")
        )

        if commit {
            let clubNickname = BIMembersProvider.photoClubBellusImagoIdPlus.nickname

            do {
                if bgContext.hasChanges {
                    try bgContext.save() // commit all changes
                }
                ifDebugPrint("\(clubNickname): completed insertSomeHardcodedMemberData()")
            } catch {
                ifDebugFatalError("\(clubNickname): ERROR - failed to save changes to Core Data",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, the failed database update is only logged. App doesn't stop.
            }
        }

    }

    private func addMember(bgContext: NSManagedObjectContext,
                           givenName: String,
                           familyName: String,
                           photographerWebsite: URL? = nil,
                           bornDT: Date? = nil,
                           photoClub: PhotoClub,
                           memberRolesAndStatus: MemberRolesAndStatus = MemberRolesAndStatus(role: [:], stat: [:]),
                           memberWebsite: URL? = nil,
                           latestImage: URL? = nil,
                           phoneNumber: String? = nil,
                           eMail: String? = nil) {
        let photographer = Photographer.findCreateUpdate(bgContext: bgContext,
                                                         givenName: givenName, familyName: familyName,
                                                         memberRolesAndStatus: memberRolesAndStatus,
                                                         photographerWebsite: photographerWebsite,
                                                         bornDT: bornDT)

        _ = MemberPortfolio.findCreateUpdate(context: bgContext, photoClub: photoClub, photographer: photographer,
                                             memberRolesAndStatus: memberRolesAndStatus,
                                             memberWebsite: memberWebsite,
                                             latestImage: latestImage)
    }

}
