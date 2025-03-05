//
//  XampleMaxMembersProvider+insertOnlineMemberData.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 27/07/2024.
//

import CoreData // for NSManagedObjectContext
import CoreLocation // for CLLocationCoordinate2DMake

extension XampleMaxMembersProvider { // fill with some initial hard-coded content

    func insertOnlineMemberData(bgContext: NSManagedObjectContext) { // runs on a background thread

        let fotogroepXampleMaxIdPlus = OrganizationIdPlus(fullName: "Xample Club Max",
                                                           town: "Amsterdam",
                                                           nickname: "XampleMax")

        bgContext.perform { // execute on background thread
            let club = Organization.findCreateUpdate(context: bgContext,
                                                     organizationTypeEnum: .club,
                                                     idPlus: fotogroepXampleMaxIdPlus,
                                                     // real coordinates added in XampleMax.level2.json
                                                     coordinates: CLLocationCoordinate2DMake(0, 0),
                                                     optionalFields: OrganizationOptionalFields() // empty fields
                                                    )
            ifDebugPrint("\(club.fullNameTown): Starting insertOnlineMemberData() in background")

            _ = Level2JsonReader(bgContext: bgContext,
                                 urlComponents: UrlComponents.xampleMax,
                                 club: club,
                                 useOnlyFile: false)
            try? bgContext.save()
        }
    }

}
