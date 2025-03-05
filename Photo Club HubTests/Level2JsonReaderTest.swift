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

        let idPlus = OrganizationIdPlus(fullName: "Xample Club Min",
                                        town: "Rotterdam",
                                        nickname: "XampleMin")

        let predicateFormat: String = "fullName_ = %@ AND town_ = %@" // avoid localization
        // Note that organizationType is not an identifying attribute.
        // This implies that you cannot have 2 organizations with the same Name and Town, but of a different type.
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [idPlus.fullName,
                                                    idPlus.town] )
        let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
        fetchRequest.predicate = predicate
        let organizations: [Organization] = (try? context.fetch(fetchRequest)) ?? []

        #expect(organizations.count == 1)
        #expect(organizations[0].organizationType.organizationTypeName == OrganizationTypeEnum.club.rawValue)
        #expect(organizations[0].fullName == idPlus.fullName)
        #expect(organizations[0].town == idPlus.town)
        #expect(organizations[0].nickname == idPlus.nickname)
    }

}
