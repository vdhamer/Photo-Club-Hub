//
//  FotogroepDeGenderMembersProvider+insertOnlineMemberData.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 13/07/2024.
//

import CoreData // for NSManagedObjectContext

extension FotogroepDeGenderMembersProvider { // fill with some initial hard-coded content

    func insertOnlineMemberData(bgContext: NSManagedObjectContext) { // runs on a background thread

        let fotogroepDeGenderIdPlus = OrganizationIdPlus(fullName: "Fotogroep de Gender",
                                                         town: "Eindhoven",
                                                         nickname: "fgDeGender")

        bgContext.perform { // execute on background thread
            let club = Organization.findCreateUpdate(context: bgContext,
                                                     organizationTypeEnum: .club,
                                                     idPlus: fotogroepDeGenderIdPlus,
                                                     optionalFields: OrganizationOptionalFields() // empty fields
                                                    )
            ifDebugPrint("\(club.fullNameTown): Starting insertOnlineMemberData() in background")

            _ = Level2JsonReader(bgContext: bgContext,
                                 urlComponents: UrlComponents.deGender,
                                 club: club,
                                 useOnlyFile: false)
        }
    }

}
