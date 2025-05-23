//
//  FotogroepDeGenderMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 29/09/2023.
//

import CoreData // for PersistenceController
import CoreLocation // for CLLocationCoordinate2DMake

class FotogroepDeGenderMembersProvider {

    init(bgContext: NSManagedObjectContext,
         synchronousWithRandomTown: Bool = false,
         randomTown: String = "RandomTown") {

        if synchronousWithRandomTown {
            bgContext.performAndWait { // execute block synchronously or ...
                self.insertOnlineMemberData(bgContext: bgContext, town: randomTown)
            }
        } else {
            bgContext.perform { // ...execute block asynchronously
                self.insertOnlineMemberData(bgContext: bgContext)
            }
        }

    }

    fileprivate func insertOnlineMemberData(bgContext: NSManagedObjectContext, town: String = "Eindhoven") {
        let fgIdPlus = OrganizationIdPlus(fullName: "Fotogroep de Gender",
                                          town: town,
                                          nickname: "fgDeGender")

        let club = Organization.findCreateUpdate(context: bgContext,
                                                 organizationTypeEnum: .club,
                                                 idPlus: fgIdPlus,
                                                 // real coordinates added in fgDeGender.level2.json
                                                 coordinates: CLLocationCoordinate2DMake(0, 0),
                                                 optionalFields: OrganizationOptionalFields() // empty fields
                                                )
        ifDebugPrint("\(club.fullNameTown): Starting insertOnlineMemberData() in background")

        _ = Level2JsonReader(bgContext: bgContext,
                             urlComponents: UrlComponents.deGender,
                             club: club,
                             useOnlyFile: false)
        do {
            try bgContext.save()
        } catch {
            ifDebugFatalError("Failed to save club \(fgIdPlus.nickname)", file: #fileID, line: #line)
        }
    }

}
