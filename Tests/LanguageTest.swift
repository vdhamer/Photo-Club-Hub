//
//  LanguageTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 29/06/2026.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests the Core Data Language class") struct LanguageTests {

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

    // Calling findCreateUpdate twice with the same ISO code must return the same object (no duplicate).
    @Test("findCreateUpdate is idempotent for a given ISO code") func idempotentForSameCode() {
        let isoCode = "qx" + String.random(length: 6) // "qx" guarantees the code contains letters

        let language1 = Language.findCreateUpdate(context: viewContext, isoCode: isoCode)
        let language2 = Language.findCreateUpdate(context: viewContext, isoCode: isoCode)

        #expect(language1 === language2) // same managed object, not a second copy
        #expect(Language.count(context: viewContext, isoCode: isoCode) == 1) // exactly one record for this code
    }

    // The documented contract is that ISO codes are matched case-insensitively ("en" → "EN").
    @Test("ISO code is matched case-insensitively") func languageIDMatchedCaseInsensitively() {
        let isoCode = "qx" + String.random(length: 6) // "qx" guarantees lower/upper actually differ

        let lower = Language.findCreateUpdate(context: viewContext, isoCode: isoCode.lowercased())
        let upper = Language.findCreateUpdate(context: viewContext, isoCode: isoCode.uppercased())

        #expect(lower === upper) // both resolve to the same object
        #expect(lower.isoCode == isoCode.uppercased()) // stored code is normalised to uppercase
        #expect(Language.count(context: viewContext, isoCode: isoCode) == 1) // still only one record
    }

    // nil update semantics: nameENOptional == nil must leave an already-set name untouched.
    @Test("nil nameENOptional does not overwrite an existing name") func nilNameDoesNotOverwrite() {
        let isoCode = "qx" + String.random(length: 6)

        let language1 = Language.findCreateUpdate(context: viewContext, isoCode: isoCode, nameENOptional: "Klingon")
        #expect(language1.nameEN == "Klingon")

        let language2 = Language.findCreateUpdate(context: viewContext, isoCode: isoCode, nameENOptional: nil)
        #expect(language2 === language1) // same object
        #expect(language2.nameEN == "Klingon") // unchanged by the nil call
    }

}
