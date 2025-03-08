//
//  XampleMaxMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/07/2021.
//

import CoreData // for PersistenceController
import CoreLocation // for CLLocationCoordinate2DMake

class XampleMaxMembersProvider {

    init(bgContext: NSManagedObjectContext) {
        insertOnlineMemberData(bgContext: bgContext)
    }

    fileprivate func insertOnlineMemberData(bgContext: NSManagedObjectContext) { // runs on a background thread

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
