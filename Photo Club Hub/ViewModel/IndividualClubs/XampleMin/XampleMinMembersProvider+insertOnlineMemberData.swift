//
//  XampleMinMembersProvider+insertOnlineMemberData.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 27/07/2024.
//

import CoreData // for NSManagedObjectContext
import CoreLocation // for CLLocationCoordinate2DMake

extension XampleMinMembersProvider { // fill with some initial hard-coded content

    func insertOnlineMemberData(bgContext: NSManagedObjectContext) { // runs on a background thread

        let fotogroepXampleMinIdPlus = OrganizationIdPlus(fullName: "Xample Club Min",
                                                          town: "Rotterdam",
                                                          nickname: "XampleMin")

        bgContext.perform { // execute on background thread
            let club = Organization.findCreateUpdate(context: bgContext,
                                                     organizationTypeEnum: .club,
                                                     idPlus: fotogroepXampleMinIdPlus,
                                                     // real coordinates added in XampleMax.level2.json
                                                     coordinates: CLLocationCoordinate2DMake(0, 0),
                                                     optionalFields: OrganizationOptionalFields() // empty fields
                                                    )
            ifDebugPrint("\(club.fullNameTown): Starting insertOnlineMemberData() in background")

            _ = Level2JsonReader(bgContext: bgContext,
                                 urlComponents: UrlComponents.xampleMin,
                                 club: club,
                                 useOnlyFile: false)
        }
    }

}
