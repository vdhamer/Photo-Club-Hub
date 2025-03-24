//
//  XampleMaxMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/07/2021.
//

import CoreData // for PersistenceController
import CoreLocation // for CLLocationCoordinate2DMake

class XampleMaxMembersProvider {

    init(bgContext: NSManagedObjectContext,
         synchronousWithRandomTown: Bool = false,
         randomTown: String = "RandomTown") {

        if synchronousWithRandomTown {
            bgContext.performAndWait { // ...or execute same block synchronously
                self.insertOnlineMemberData(bgContext: bgContext, town: randomTown)
            }
        } else {
            bgContext.perform { // execute block asynchronously...
                self.insertOnlineMemberData(bgContext: bgContext)
            }
        }

    }

    fileprivate func insertOnlineMemberData(bgContext: NSManagedObjectContext, town: String = "Amsterdam") {
        let fgIdPlus = OrganizationIdPlus(fullName: "Xample Club Max",
                                          town: town,
                                          nickname: "XampleMax")

        let club = Organization.findCreateUpdate(context: bgContext,
                                                 organizationTypeEnum: .club,
                                                 idPlus: fgIdPlus,
                                                 // real coordinates added in XampleMax.level2.json
                                                 coordinates: CLLocationCoordinate2DMake(0, 0),
                                                 optionalFields: OrganizationOptionalFields() // empty fields
        )
        ifDebugPrint("\(club.fullNameTown): Starting insertOnlineMemberData() in background")

        _ = Level2JsonReader(bgContext: bgContext,
                             urlComponents: UrlComponents.xampleMax,
                             club: club,
                             useOnlyFile: false)
        do {
            try bgContext.save()
        } catch {
            ifDebugFatalError("Failed to save club \(fgIdPlus.nickname)", file: #fileID, line: #line)
        }

    }

}
