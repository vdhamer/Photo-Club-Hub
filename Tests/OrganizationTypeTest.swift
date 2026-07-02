//
//  OrganizationTypeTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 29/06/2026.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests the Core Data OrganizationType class") struct OrganizationTypeTests {

    private let testPersistenceController: PersistenceController
    private let viewContext: NSManagedObjectContext

    init () {
        // Use a private in-memory store rather than PersistenceController.shared. Sharing the singleton
        // coordinator across parallel suites deadlocks (main-queue performAndWait fetches contending with
        // background-context saves) and lets suites pollute each other's records. See issue #756.
        testPersistenceController = PersistenceController(inMemory: true)
        viewContext = testPersistenceController.container.viewContext
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    // Counts OrganizationType records matching the given (identifying) type name.
    private func count(_ orgTypeName: String) -> Int {
        let predicate = NSPredicate(format: "organizationTypeName_ = %@", argumentArray: [orgTypeName])
        let fetchRequest: NSFetchRequest<OrganizationType> = OrganizationType.fetchRequest()
        fetchRequest.predicate = predicate
        return ((try? viewContext.fetch(fetchRequest)) ?? []).count
    }

    // Calling findCreateUpdate twice with the same type name must return the same object (no duplicate).
    @Test("findCreateUpdate is idempotent for a given type name") func idempotentForSameName() {
        let orgTypeName = "unittest-" + String.random(length: 10) // avoid clashing with seeded club/museum/unknown

        let type1 = OrganizationType.findCreateUpdate(context: viewContext, orgTypeName: orgTypeName)
        let type2 = OrganizationType.findCreateUpdate(context: viewContext, orgTypeName: orgTypeName)

        #expect(type1 === type2) // same managed object, not a second copy
        #expect(type1.organizationTypeName == orgTypeName)
        #expect(count(orgTypeName) == 1) // exactly one record exists for this name
    }

}
