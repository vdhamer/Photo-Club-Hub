//
//  Level2JsonReaderTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 05/03/2025.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests the Core Data Keyword class") struct Level2JsonReaderTests {

    fileprivate let context: NSManagedObjectContext

    init () {
        context = PersistenceController.shared.container.viewContext
    }

    // Read XampleMin.level2.json and check for parsing errors
    @Test("Parse XampleMin.level2.json") func xampleMinParse() async throws {
        let xampleMinBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
        xampleMinBackgroundContext.name = "XampleMin"
        xampleMinBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        xampleMinBackgroundContext.automaticallyMergesChangesFromParent = true

        // note that club XampleMin may already be loaded
        // note that XampleMinMembersProvider runs asynchronously (via bgContext.perform {})
        _ = XampleMinMembersProvider(bgContext: xampleMinBackgroundContext)

        #expect(true)
    }

}
