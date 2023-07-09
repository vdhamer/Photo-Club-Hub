//
//  TestClubAmsterdamMembersProvider+insertSomeHardcodedMemberData.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 11/01/2023.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension TestClubAmsterdamMembersProvider { // fill with some initial hard-coded content

    private static let testAmsterdamURL = URL(string: "https://www.foam.org")
    static let photoClubTestAmsterdamIdPlus = PhotoClubIdPlus(fullName: "Test Fotoclub",
                                                              town: "Amsterdam", // Rotterdam also has a "Test Fotoclub"
                                                              nickname: "FC Test Adam")

    func insertSomeHardcodedMemberData(bgContext: NSManagedObjectContext) {
        bgContext.perform {
            ifDebugPrint("Photo Club Test Adam: starting insertSomeHardcodedMemberData() in background")
            self.insertSomeHardcodedMemberDataCommon(bgContext: bgContext, commit: true)
        }
    }

    private func insertSomeHardcodedMemberDataCommon(bgContext: NSManagedObjectContext, commit: Bool) {

        // add photo club to Photo Clubs (if needed)
        let clubTestAmsterdam = PhotoClub.findCreateUpdate(
                                                 bgContext: bgContext,
                                                 photoClubIdPlus: Self.photoClubTestAmsterdamIdPlus,
                                                 photoClubWebsite: TestClubAmsterdamMembersProvider.testAmsterdamURL,
                                                 fotobondNumber: nil, kvkNumber: nil,
                                                 coordinates: CLLocationCoordinate2D(latitude: 52.364217,
                                                                                     longitude: 4.893370),
                                                 priority: 1
                                                )
        clubTestAmsterdam.hasHardCodedMemberData = true // store in database that we ran insertSomeHardcodedMembers...

        addMember(context: bgContext,
                  givenName: "Peter",
                  familyName: "van den Hamer",
                  photoClub: clubTestAmsterdam,
                  memberRolesAndStatus: MemberRolesAndStatus(role: [ .secretary: true ], stat: [ .former: false]),
                  memberWebsite: URL(string: "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testA")!,
                  latestImage: URL(string:
                     "https://www.fotogroepwaalre.nl/fotos/Peter_van_den_Hamer_testA/" +
                                                    "thumbs/2022_Iceland_R5_013.jpg")!,
//                  phoneNumber: nil,
                  eMail: "foobarA@vdhamer.com"
        )

        if commit {
            do {
                if bgContext.hasChanges { // is this necessary? sometimes save() done earlier
                    try bgContext.save() // commit all changes
                }
                ifDebugPrint("Photo Club TestAmsterdam: completed insertSomeHardcodedMemberData()")
            } catch {
                ifDebugFatalError("Failed to save changes for Test Amsterdam",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, failing to store the data is only logged. And the app doesn't stop.
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
                            bgContext: context, // TODO - check MOC
                            givenName: givenName, familyName: familyName,
                            memberRolesAndStatus: memberRolesAndStatus,
                            bornDT: bornDT )

        _ = MemberPortfolio.findCreateUpdate(
                            context: context, photoClub: photoClub, photographer: photographer,
                            memberRolesAndStatus: memberRolesAndStatus,
                            memberWebsite: memberWebsite,
                            latestImage: latestImage)
    }

}
