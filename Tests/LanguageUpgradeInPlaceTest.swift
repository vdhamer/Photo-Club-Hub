//
//  LanguageUpgradeInPlaceTest.swift
//  Photo Club HubTests
//
//  Created by Claude Code (guided by Peter van den Hamer) on 02/08/2026.
//

import Testing
import Foundation
import CoreData // for NSManagedObjectContext, NSEntityDescription
import Photo_Club_Hub_Data // for Language, Level0JsonReader, PersistenceController

// #769 risk 1 / step 8(c). Shipped versions stored ISO codes inconsistently, so real stores in the
// field contain uppercase isoCode_ values such as "NL". Language lookups use an "isoCode_ =[c] %@"
// predicate so those rows still match; with an exact-match predicate findCreateUpdate would miss them
// and insert a duplicate Language instead.
//
// The package already unit-tests the predicate itself. This test deliberately covers the layer above:
// a populated store opened through the app's Core Data stack, upgraded by a real Level 0 load. Note
// the bundled root.level0.json genuinely contains uppercase codes ("EN", "NL", "DE"), which is how
// such rows came to exist in the first place.
//
// Every touch of bgContext goes through perform { }. The test plan runs with
// -com.apple.CoreData.ConcurrencyDebug 1, which traps any access to a private-queue context from
// another queue — including from this @MainActor suite.
@MainActor
@Suite("Tests that a legacy uppercase Language row survives a Level 0 load")
struct LanguageUpgradeInPlaceTests {

    private let persistenceController: PersistenceController

    init() {
        // A private in-memory store rather than PersistenceController.shared: sharing the singleton
        // coordinator across parallel suites lets them pollute each other's records (see Data repo #756).
        persistenceController = PersistenceController(inMemory: true)
    }

    // Returns every stored isoCode_, read on the context's own queue.
    private func storedIsoCodes(_ context: NSManagedObjectContext) async -> [String] {
        await context.perform {
            let languages = (try? context.fetch(Language.fetchRequest())) ?? []
            return languages.compactMap { $0.isoCode_ }.sorted()
        }
    }

    @Test("A legacy uppercase isoCode_ row is matched and normalized, not duplicated")
    func legacyUppercaseRowIsNotDuplicated() async throws {
        let bgContext = persistenceController.container.newBackgroundContext()
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        // Seed the store the way a shipped version would have left it: isoCode_ written directly, so
        // the value bypasses the lowercasing that every current write path applies.
        await bgContext.perform {
            let entity = NSEntityDescription.entity(forEntityName: "Language", in: bgContext)!
            let legacy = Language(entity: entity, insertInto: bgContext)
            legacy.isoCode_ = "NL"
            legacy.languageNameEN_ = "Dutch"
            try? bgContext.save()
        }

        let before = await storedIsoCodes(bgContext)
        #expect(before == ["NL"], "precondition: exactly one row, uppercase. Got \(before)")

        // Run a real Level 0 load against that store. useOnlyInBundleFile avoids the network so the
        // test is deterministic; isBeingTested stays false so the production root.level0.json is used.
        _ = Level0JsonReader(bgContext: bgContext,
                             isBeingTested: false,
                             useOnlyInBundleFile: true)

        // Level0JsonReader's initializer returns immediately: it wraps its work in bgContext.perform { }.
        // Blocks on one context's queue run FIFO, so an empty perform after it completes only once the
        // load has finished.
        await bgContext.perform { }

        let after = await storedIsoCodes(bgContext)

        // The seeded row must have been found and normalized in place, not duplicated.
        #expect(!after.contains("NL"), "Legacy uppercase row survived unnormalized: \(after)")
        #expect(after.contains("nl"), "Dutch row disappeared entirely: \(after)")

        // No two rows may share an ISO code once case is ignored.
        let lowercased = after.map { $0.lowercased() }
        #expect(lowercased.count == Set(lowercased).count, "Duplicate Language records after upgrade: \(after)")
    }
}
