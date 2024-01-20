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
    private static let photoClubBellusImagoIdPlus = OrganizationIdPlus(fullName: "Fotoclub Bellus Imago",
                                                                       town: "Veldhoven",
                                                                       nickname: "FC BellusImago")

    func insertSomeHardcodedMemberData(bgContext: NSManagedObjectContext) {
        bgContext.perform { // from here on, we are running on a background thread
            self.insertSomeHardcodedMemberDataCommon(bgContext: bgContext)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(bgContext: NSManagedObjectContext) {

        // add Bellus Imago to Photo Clubs (if needed)
        let clubBellusImago = Organization.findCreateUpdate(
                                                            context: bgContext,
                                                            organizationTypeEum: .club,
                                                            idPlus: Self.photoClubBellusImagoIdPlus
                                                           )

        ifDebugPrint("""
                     \(clubBellusImago.fullNameTown): \
                     Starting insertSomeHardcodedMemberData() in background
                     """)
        clubBellusImago.hasHardCodedMemberData = true // store in database that we ran insertSomeHardcodedMembers...

        addMember(bgContext: bgContext, // add Rico to Photographers and member of Bellus (if needed)
                  personName: PersonName(givenName: "Rico", infixName: "", familyName: "Coolen"),
                  photographerWebsite: URL(string: "https://www.ricoco.nl"),
                  organization: clubBellusImago,
                  memberWebsite: URL(string: "https://www.fotoclubbellusimago.nl/rico.html"),
                  latestImage: URL(string:
                     "https://www.fotoclubbellusimago.nl/uploads/5/5/1/2/55129719/vrijwerk-rico-3_orig.jpg"),
                  eMail: "info@ricoco.nl"
        )

        addMember(bgContext: bgContext, // add Loek to Photographers and member of Bellus (if needed)
                  personName: PersonName(givenName: "Loek", infixName: "", familyName: "Dirkx"),
                  organization: clubBellusImago,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: true ]),
                  memberWebsite: URL(string: "https://www.fotoclubbellusimago.nl/loek.html"),
                  latestImage: URL(string:
                     "https://www.fotoclubbellusimago.nl/uploads/5/5/1/2/55129719/vrijwerk-loek-1_2_orig.jpg")
        )

        let clubNickname = BellusImagoMembersProvider.photoClubBellusImagoIdPlus.nickname

        do {
//            if bgContext.hasChanges {
                try bgContext.save() // persist FG Bellus Imago and its members
                print("*** Updating *** SAVING instance=\"\(clubBellusImago.fullName)\"")
//            }
            ifDebugPrint("""
                         \(clubBellusImago.fullNameTown): \
                         Completed insertSomeHardcodedMemberData() in background
                         """)
        } catch {
            ifDebugFatalError("\(clubNickname): ERROR - failed to save changes to Core Data",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, the failed database update is only logged. App doesn't stop.
        }

    }

    private func addMember(bgContext: NSManagedObjectContext,
                           personName: PersonName,
                           photographerWebsite: URL? = nil,
                           bornDT: Date? = nil,
                           organization: Organization,
                           memberRolesAndStatus: MemberRolesAndStatus = MemberRolesAndStatus(role: [:], stat: [:]),
                           memberWebsite: URL? = nil,
                           latestImage: URL? = nil,
                           latestThumbnail: URL? = nil,
                           phoneNumber: String? = nil,
                           eMail: String? = nil) {

        let photographer = Photographer.findCreateUpdate(context: bgContext,
                                                         personName: personName,
                                                         memberRolesAndStatus: memberRolesAndStatus,
                                                         photographerWebsite: photographerWebsite,
                                                         bornDT: bornDT,
                                                         organization: organization)

        let image = latestImage ?? latestThumbnail // if image not available, use thumbnail (which might also be nil)
        let thumb = latestThumbnail ?? latestImage // if thumb not available, use image (which might also be nil)
        _ = MemberPortfolio.findCreateUpdate(bgContext: bgContext,
                                             organization: organization, photographer: photographer,
                                             memberRolesAndStatus: memberRolesAndStatus,
                                             memberWebsite: memberWebsite,
                                             latestImage: image,
                                             latestThumbnail: thumb)
    }

}
