//
//  AndersMembersProvider+insertOnlineMemberData.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 21/07/2024.
//

import CoreData // for NSManagedObjectContext

extension AndersMembersProvider { // fill with some initial hard-coded content

    func insertOnlineMemberData(bgContext: NSManagedObjectContext) { // runs on a background thread

        let fotogroepAndersIdPlus = OrganizationIdPlus(fullName: "Fotogroep Anders",
                                                       town: "Eindhoven",
                                                       nickname: "FG Anders")

        bgContext.perform { // execute on background thread
            let club = Organization.findCreateUpdate(context: bgContext,
                                                     organizationTypeEnum: .club,
                                                     idPlus: fotogroepAndersIdPlus,
                                                     optionalFields: OrganizationOptionalFields() // empty
                                                    )
            ifDebugPrint("\(club.fullNameTown): Starting insertOnlineMemberData() in background")

            _ = Level2JsonReader(bgContext: bgContext,
                                 urlComponents: UrlComponents.anders,
                                 club: club,
                                 useOnlyFile: false)
        }
    }

}
