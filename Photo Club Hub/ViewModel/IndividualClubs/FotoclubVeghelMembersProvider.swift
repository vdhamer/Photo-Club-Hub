//
//  FotoclubVeghel.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/01/2026.
//

import CoreData // for PersistenceController

final public class FotoclubVeghelMembersProvider: Sendable {

    public init(bgContext: NSManagedObjectContext,
                isBeingTested: Bool,
                useOnlyInBundleFile: Bool = false,
                randomTownForTesting: String? = nil) {

        if isBeingTested {
            guard let randomTownForTesting else {
                ifDebugFatalError("Missing randomTownForTesting", file: #file, line: #line)
                return
            }
            bgContext.performAndWait { // execute block synchronously
                insertOnlineMemberData(bgContext: bgContext,
                                       isBeingTested: isBeingTested,
                                       town: randomTownForTesting,
                                       useOnlyInBundleFile: useOnlyInBundleFile)
            }
        } else {
            bgContext.perform { // ... or execute same block asynchronously
                self.insertOnlineMemberData(bgContext: bgContext,
                                            isBeingTested: isBeingTested,
                                            useOnlyInBundleFile: useOnlyInBundleFile)
            }
        }

    }

    private func insertOnlineMemberData(bgContext: NSManagedObjectContext,
                                        isBeingTested: Bool,
                                        town: String = "Veghel",
                                        useOnlyInBundleFile: Bool) {
        let idPlus = OrganizationIdPlus(fullName: "Fotoclub Veghel",
                                        town: town,
                                        nickname: "fcVeghel")

        let club = Organization.findCreateUpdate(context: bgContext,
                                                 organizationTypeEnum: .club,
                                                 idPlus: idPlus
                                                )
        ifDebugPrint("\(club.fullNameTown): Starting insertOnlineMemberData() in background")

        _ = Level2JsonReader(bgContext: bgContext,
                             organizationIdPlus: idPlus,
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: useOnlyInBundleFile)
        do {
            if bgContext.hasChanges {
                try bgContext.save()
            }
        } catch {
            ifDebugFatalError("Failed to save club \(idPlus.nickname)", file: #fileID, line: #line)
        }

    }

}
