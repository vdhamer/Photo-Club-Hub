//
//  FotogroepWaalreMembersProvider+insertOnlineMemberData.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 04/08/2024.
//

import CoreData // for NSManagedObjectContext
import CoreLocation // for CLLocationCoordinate2DMake

extension FotogroepWaalreMembersProvider { // fill with some initial hard-coded content

    func insertOnlineMemberData(bgContext: NSManagedObjectContext) { // runs on a background thread

        let fotogroepWaalreIdPlus = OrganizationIdPlus(fullName: "Fotogroep Waalre",
                                                       town: "Waalre",
                                                       nickname: "fgWaalre")

        bgContext.perform { // execute on background thread
            let club = Organization.findCreateUpdate(context: bgContext,
                                                     organizationTypeEnum: .club,
                                                     idPlus: fotogroepWaalreIdPlus,
                                                     // real coordinates added in fgWaalre.level2.json
                                                     coordinates: CLLocationCoordinate2DMake(0, 0),
                                                     optionalFields: OrganizationOptionalFields() // empty fields
                                                    )
            ifDebugPrint("\(club.fullNameTown): Starting insertOnlineMemberData() in background")

            _ = Level2JsonReader(bgContext: bgContext,
                                 urlComponents: UrlComponents.waalre,
                                 club: club,
                                 useOnlyFile: false)
        }
    }

}
