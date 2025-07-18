//
//  XampleMaxMembersProvider.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/07/2021.
//

import CoreData // for PersistenceController

public class XampleMaxMembersProvider {

    public init(bgContext: NSManagedObjectContext,
                useOnlyInBundleFile: Bool = false,
                synchronousWithRandomTown: Bool = false,
                randomTown: String = "RandomTown") {

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

    fileprivate func insertOnlineMemberData(bgContext: NSManagedObjectContext, town: String = "Rotterdam") {
        let idPlus = OrganizationIdPlus(fullName: "Xample Club With Maximal Data",
                                        town: town,
                                        nickname: "XampleMax")

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
