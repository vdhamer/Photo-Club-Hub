//
//  IndividueelBOMemebersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 06/07/2025.
//

import CoreData // for PersistenceController

public class IndividueelBOMembersProvider {

    public init(bgContext: NSManagedObjectContext,
                useOnlyInBundleFile: Bool = false,
                synchronousWithRandomTown: Bool = false, // for testing
                randomTown: String = "RandomTown") { // for testing

        if synchronousWithRandomTown {
            bgContext.performAndWait { // ...or execute same block synchronously
                insertOnlineMemberData(bgContext: bgContext, town: randomTown)
            }
        } else {
            bgContext.perform { // execute block asynchronously...
                self.insertOnlineMemberData(bgContext: bgContext)
            }
        }

    }

    fileprivate func insertOnlineMemberData(bgContext: NSManagedObjectContext, town: String = "Eindhoven") {
        let idPlus = OrganizationIdPlus(fullName: "Individuele Leden Brabant Oost",
                                        town: town,
                                        nickname: "IndividueelBO")

        let club = Organization.findCreateUpdate(context: bgContext,
                                                 organizationTypeEnum: .club,
                                                 idPlus: idPlus)
        ifDebugPrint("\(club.fullNameTown): Starting insertOnlineMemberData() in background")

        _ = Level2JsonReader(bgContext: bgContext,
                             organizationIdPlus: idPlus,
                             isInTestBundle: false,
                             useOnlyInBundleFile: false)
        do {
            try bgContext.save()
        } catch {
            ifDebugFatalError("Failed to save club \(idPlus.nickname)", file: #fileID, line: #line)
        }

    }

}
