//
//  FotogroepWaalreMembersProvider+insertSomeHardcodedMemberData.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 01/08/2021.
//

import CoreData // for NSManagedObjectContext
import MapKit // for CLLocationCoordinate2D

extension FotogroepWaalreMembersProvider { // fill with some initial hard-coded content

    // swiftlint:disable:next function_body_length
    func insertSomeHardcodedMemberData(bgContext: NSManagedObjectContext) { // runs on a background thread

        let clubWaalre = Organization.findCreateUpdate(
                                        context: bgContext,
                                        organizationTypeEnum: .club,
                                        idPlus: FotogroepWaalreMembersProvider.photoClubWaalreIdPlus,
                                        optionalFields: OrganizationOptionalFields() // empty
                                       )
        ifDebugPrint("""
                     \(clubWaalre.fullNameTown): \
                     Starting insertSomeHardcodedMemberData() in background
                     """)
        clubWaalre.hasHardCodedMemberData = true // store in database that we ran insertSomeHardcodedMembers...

        addMember(bgContext: bgContext,
                  personName: PersonName(givenName: "Carel", infixName: "", familyName: "Bullens"),
                  organization: clubWaalre,
                  memberOptionalFields: MemberOptionalFields(
                        memberRolesAndStatus: MemberRolesAndStatus(role: [ .viceChairman: true ], status: [:])),
                  photographerOptionalFields: PhotographerOptionalFields()
                  )

        addMember(bgContext: bgContext,
                  personName: PersonName(givenName: "Erik", infixName: "van", familyName: "Geest"),
                  organization: clubWaalre,
                  memberOptionalFields: MemberOptionalFields(
                        memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true ])),
                  photographerOptionalFields: PhotographerOptionalFields()
                  )

        addMember(bgContext: bgContext,
                  personName: PersonName(givenName: "Henriëtte", infixName: "van", familyName: "Ekert"),
                  organization: clubWaalre,
                  memberOptionalFields: MemberOptionalFields(
                        memberRolesAndStatus: MemberRolesAndStatus(role: [ .admin: true ])),
                  photographerOptionalFields: PhotographerOptionalFields()
                  )

        addMember(bgContext: bgContext,
                  personName: PersonName(givenName: "Jos", infixName: "", familyName: "Jansen"),
                  organization: clubWaalre,
                  memberOptionalFields: MemberOptionalFields(
                        memberRolesAndStatus: MemberRolesAndStatus(role: [ .treasurer: true ])),
                  photographerOptionalFields: PhotographerOptionalFields()
                  )

        addMember(bgContext: bgContext,
                  personName: PersonName(givenName: "Kees", infixName: "van", familyName: "Gemert"),
                  organization: clubWaalre,
                  memberOptionalFields: MemberOptionalFields(
                        memberRolesAndStatus: MemberRolesAndStatus(role: [ .secretary: true ])),
                  photographerOptionalFields: PhotographerOptionalFields()
                  )

        addMember(bgContext: bgContext,
                  personName: PersonName(givenName: "Marijke", infixName: "", familyName: "Gallas"),
                  organization: clubWaalre,
                  memberOptionalFields: MemberOptionalFields(
                        memberRolesAndStatus: MemberRolesAndStatus(role: [:], status: [ .honorary: true ])),
                  photographerOptionalFields: PhotographerOptionalFields()
                  )

        addMember(bgContext: bgContext,
                  personName: PersonName(givenName: "Miek", infixName: "", familyName: "Kerkhoven"),
                  organization: clubWaalre,
                  memberOptionalFields: MemberOptionalFields(
                        memberRolesAndStatus: MemberRolesAndStatus(role: [ .chairman: true ])),
                  photographerOptionalFields: PhotographerOptionalFields()
                  )

        do {
            if Settings.extraCoreDataSaves && bgContext.hasChanges { // hasChanges is for optimization only
                try bgContext.save() // persist FotoGroep Waalre and its online member data
            }
            ifDebugPrint("""
                         \(clubWaalre.fullNameTown): \
                         Completed insertSomeHardcodedMemberData() in background
                         """)
        } catch {
            ifDebugFatalError("Fotogroep Waalre: ERROR - failed to save changes to Core Data",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, the failed database inserts are only logged. App doesn't stop.
        }

    }

    private func addMember(bgContext: NSManagedObjectContext,
                           personName: PersonName,
                           organization: Organization,
                           memberOptionalFields: MemberOptionalFields,
                           photographerOptionalFields: PhotographerOptionalFields
    ) {
        let photographer = Photographer.findCreateUpdate(
                           context: bgContext,
                           personName: PersonName(givenName: personName.givenName,
                                                  infixName: personName.infixName,
                                                  familyName: personName.familyName),
                           organization: organization, // only used for debug messages
                           isDeceased: memberOptionalFields.memberRolesAndStatus.isDeceased(),
                           optionalFields: photographerOptionalFields)

        _ = MemberPortfolio.findCreateUpdate(
                            bgContext: bgContext,
                            organization: organization, photographer: photographer,
                            optionalFields: memberOptionalFields
                            )
        // do not need to bgContext.save() because a series of hardcoded members will be saved simultaneously
    }
}
