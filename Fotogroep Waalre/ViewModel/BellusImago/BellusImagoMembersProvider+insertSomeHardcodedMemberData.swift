//
//  BellusImagoMembersProvider+insertSomeHardcodedMemberData.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 01/08/2021.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension BellusImagoMembersProvider { // fill with some initial hard-coded content

    private static let bellusImagoURL = URL(string: "https://www.fotoClubBellusImago.nl")
    private static let photoClubBellusImagoIdPlus = PhotoClubIdPlus(fullName: "Fotoclub Bellus Imago",
                                                                    town: "Veldhoven",
                                                                    nickname: "FC BellusImago")

    func insertSomeHardcodedMemberData(bgContext: NSManagedObjectContext) {
        bgContext.perform { // from here on, we are running on a background thread
            ifDebugPrint("""
                         \(Self.photoClubBellusImagoIdPlus.fullNameTown): \
                         Starting insertSomeHardcodedMemberData() in background
                         """)
            self.insertSomeHardcodedMemberDataCommon(bgContext: bgContext)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(bgContext: NSManagedObjectContext) {

        // add Bellus Imago to Photo Clubs (if needed)
        let clubBellusImago = PhotoClub.findCreateUpdate(
                                                         context: bgContext,
                                                         photoClubIdPlus: Self.photoClubBellusImagoIdPlus,
                                                         photoClubWebsite: BellusImagoMembersProvider.bellusImagoURL,
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

        let clubNickname = BellusImagoMembersProvider.photoClubBellusImagoIdPlus.nickname

        do {
            if bgContext.hasChanges {
                try bgContext.save() // commit all changes
            }
            ifDebugPrint("""
                         \(Self.photoClubBellusImagoIdPlus.fullNameTown): \
                         Completed insertSomeHardcodedMemberData() in background
                         """)
        } catch {
            ifDebugFatalError("\(clubNickname): ERROR - failed to save changes to Core Data",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, the failed database update is only logged. App doesn't stop.
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
        let photographer = Photographer.findCreateUpdate(context: bgContext,
                                                         givenName: givenName, familyName: familyName,
                                                         memberRolesAndStatus: memberRolesAndStatus,
                                                         photographerWebsite: photographerWebsite,
                                                         bornDT: bornDT,
                                                         photoClub: photoClub)

        _ = MemberPortfolio.findCreateUpdate(bgContext: bgContext, photoClub: photoClub, photographer: photographer,
                                             memberRolesAndStatus: memberRolesAndStatus,
                                             memberWebsite: memberWebsite,
                                             latestImage: latestImage)
    }

}
