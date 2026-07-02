//
//  PhotographerTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 29/06/2026.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests the Core Data Photographer class") struct PhotographerTests {

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

    // Counts Photographer records matching the (givenName, infixName, familyName) identity.
    private func count(_ personName: PersonName) -> Int {
        let predicateFormat = "givenName_ = %@ AND infixName_ = %@ AND familyName_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray:
                                                [personName.givenName, personName.infixName, personName.familyName])
        let fetchRequest: NSFetchRequest<Photographer> = Photographer.fetchRequest()
        fetchRequest.predicate = predicate
        return ((try? viewContext.fetch(fetchRequest)) ?? []).count
    }

    // Calling findCreateUpdate twice with the same PersonName must return the same object (no duplicate).
    @Test("findCreateUpdate is idempotent for an identical PersonName") func idempotentForSameName() {
        let personName = PersonName(givenName: String.random(length: 10),
                                    infixName: "",
                                    familyName: "UnitTestDummy")

        let photographer1 = Photographer.findCreateUpdate(context: viewContext, personName: personName)
        let photographer2 = Photographer.findCreateUpdate(context: viewContext, personName: personName)

        #expect(photographer1 === photographer2) // same managed object, not a second copy
        #expect(count(personName) == 1) // exactly one record exists for this identity
        #expect(photographer1.givenName == personName.givenName)
        #expect(photographer1.infixName == personName.infixName)
        #expect(photographer1.familyName == personName.familyName)
    }

    // nil update semantics: a nil optional field must leave an already-set value untouched.
    @Test("nil optional field does not overwrite an existing value") func nilOptionalFieldDoesNotOverwrite() {
        let personName = PersonName(givenName: String.random(length: 10),
                                    infixName: "",
                                    familyName: "UnitTestDummy")
        let website = URL(string: "https://example.com/\(String.random(length: 8))")!

        let photographer1 = Photographer.findCreateUpdate(
            context: viewContext,
            personName: personName,
            optionalFields: PhotographerOptionalFields(photographerWebsite: website))
        #expect(photographer1.photographerWebsite == website)

        // default optionalFields has photographerWebsite == nil
        let photographer2 = Photographer.findCreateUpdate(context: viewContext, personName: personName)
        #expect(photographer2 === photographer1) // same object
        #expect(photographer2.photographerWebsite == website) // unchanged by the nil call
    }

}
