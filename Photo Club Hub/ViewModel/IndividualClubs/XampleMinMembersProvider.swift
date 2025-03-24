//
//  ExampleMinMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/07/2021.
//

import CoreData // for PersistenceController
import CoreLocation // for CLLocationCoordinate2DMake

class XampleMinMembersProvider {

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

    fileprivate func insertOnlineMemberData(bgContext: NSManagedObjectContext, town: String = "Rotterdam") {
        let fgIdPlus = OrganizationIdPlus(fullName: "Xample Club Min",
                                          town: town,
                                          nickname: "XampleMin")

        let club = Organization.findCreateUpdate(context: bgContext,
                                                 organizationTypeEnum: .club,
                                                 idPlus: fgIdPlus,
                                                 // real coordinates added in XampleMin.level2.json
                                                 coordinates: CLLocationCoordinate2DMake(0, 0),
                                                 optionalFields: OrganizationOptionalFields() // empty fields
        )
        ifDebugPrint("\(club.fullNameTown): Starting insertOnlineMemberData() in background")

        _ = Level2JsonReader(bgContext: bgContext,
                             urlComponents: UrlComponents.xampleMin,
                             club: club,
                             useOnlyFile: false)
        do {
            try bgContext.save()
        } catch {
            ifDebugFatalError("Failed to save club \(fgIdPlus.nickname)", file: #fileID, line: #line)
        }

    }

}
