//
//  MalformedJsonReaderTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 25/07/2026.
//

import Testing // for macros like @Test
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

private let isBeingTested = true

// Other reader suites feed *well-formed* bundled JSON. This suite exercises the error paths that
// matter most for remotely-hosted, hand-edited JSON: garbage/truncated files and files missing a
// required key. The readers route those failures through `ifDebugFatalError`, so where a diagnostic is
// expected we install an `IfDebugFatalErrorSpy` (which records the message and returns the RELEASE-mode
// path instead of crashing the test run) and assert on it. Where the input is *silently* tolerated
// (SwiftyJSON turns unparseable text into a null document), we assert that no records are created and the
// reader simply does nothing. See issue #783.
//
// The test JSON lives in `Tests/JSON/` with names the app never loads, so they don't interfere with the
// app's concurrent background loading in the global `level1History` and won't be mistaken for real data.
@MainActor @Suite("Tests malformed / error-path JSON parsing") struct MalformedJsonReaderTests {

    // MARK: - Init

    private let testPersistenceController: PersistenceController
    private let viewContext: NSManagedObjectContext

    init () {
        // Each test gets its own private in-memory store so the app's concurrent background data-loading
        // into PersistenceController.shared cannot pollute the counts below. Swift Testing creates a fresh
        // suite instance (and thus a fresh init) per test, so the store is effectively per-test.
        testPersistenceController = PersistenceController(inMemory: true) // inMemory is important for isolation
        viewContext = testPersistenceController.container.viewContext
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        // The empty store lacks the constant records the app seeds at launch; seed them here.
        // Organizations reference OrganizationType, so OrganizationType (and Language) must exist first.
        // Must run on the main-queue viewContext (initConstants does a bare save()). See #749.
        Language.initConstants(context: viewContext)
        OrganizationType.initConstants(context: viewContext)
    }

    // MARK: - Helpers

    // Makes a background context wired up the same way the app's loaders configure one.
    private func makeBackgroundContext(named name: String) -> NSManagedObjectContext {
        let bgContext = testPersistenceController.container.newBackgroundContext()
        bgContext.name = name
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true
        return bgContext
    }

    // The readers do their work asynchronously on `bgContext.perform { }`. None of the malformed fixtures
    // contain Includes, so the whole parse runs inside that single block on the context's serial queue;
    // enqueueing an empty `performAndWait` afterwards therefore acts as a barrier — it cannot run until the
    // load block has finished.
    private func waitForLoad(on bgContext: NSManagedObjectContext) {
        bgContext.performAndWait { }
    }

    // Total number of Organizations in a context (all types), used to assert "nothing was created".
    private func organizationCount(in bgContext: NSManagedObjectContext) -> Int {
        bgContext.performAndWait {
            let request: NSFetchRequest<Organization> = Organization.fetchRequest()
            return (try? bgContext.fetch(request).count) ?? 0
        }
    }

    // The visited-file guard is a process-wide singleton shared with the app's background loading.
    // Clearing it before a Level 1 load ensures the requested file is actually parsed rather than skipped.
    private func clearVisitedHistory() {
        if #available(iOS 18, macOS 15, *) {
            Level1JsonReader.level1History.clear()
        }
    }

    // MARK: - Level 0

    // Garbage (non-JSON) input: SwiftyJSON turns it into a null document, so the reader finds no
    // expertises and no languages and quietly does nothing — no records, no crash.
    // No spy is installed: this path never reaches an ifDebugFatalError guard, so a spy would only risk
    // recording a stray diagnostic from the app's parallel background loading (the spy is process-global).
    // The test reaching its assertions at all is the "did not crash" guarantee.
    @Test("Level 0: garbage input is tolerated (no records)") func level0GarbageIsGraceful() {
        let bgContext = makeBackgroundContext(named: "garbageLevel0")

        _ = Level0JsonReader(bgContext: bgContext,
                             fileName: "garbage",
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: true)
        waitForLoad(on: bgContext)

        #expect(Expertise.count(context: bgContext) == 0)
        #expect(LocalizedExpertise.count(context: bgContext) == 0)
    }

    // A well-formed file whose single expertise is missing the required `idString`: the reader must skip it
    // (create nothing) and record the expected diagnostic via ifDebugFatalError.
    @Test("Level 0: expertise missing idString is reported and skipped") func level0MissingIdString() {
        let bgContext = makeBackgroundContext(named: "expertiseMissingIdString")

        let spy = makeIfDebugFatalErrorSpy()
        installIfDebugFatalErrorSpy(spy)
        defer { removeIfDebugFatalErrorSpy() }

        _ = Level0JsonReader(bgContext: bgContext,
                             fileName: "expertiseMissingIdString",
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: true)
        waitForLoad(on: bgContext)

        #expect(Expertise.count(context: bgContext) == 0) // the sole expertise was skipped
        #expect(spy.messages.contains { $0.contains("missing an idString field") })
    }

    // MARK: - Level 1

    // Garbage (non-JSON) input: SwiftyJSON yields a null document, so no organizations are created and the
    // reader simply loads nothing. As with the Level 0 case above, no spy is installed: the path never
    // reaches an ifDebugFatalError guard, and reaching the assertions is the "did not crash" guarantee.
    @Test("Level 1: garbage input is tolerated (no organizations)") func level1GarbageIsGraceful() {
        let bgContext = makeBackgroundContext(named: "garbageLevel1")

        clearVisitedHistory()
        _ = Level1JsonReader(bgContext: bgContext,
                             fileName: "garbage",
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: true)
        waitForLoad(on: bgContext)

        #expect(organizationCount(in: bgContext) == 0)
    }

    // A truncated (cut off mid-token) file is likewise unparseable: SwiftyJSON returns a null document and
    // the reader creates no organizations rather than crashing on the partial data.
    @Test("Level 1: truncated input is tolerated (no organizations)") func level1TruncatedIsGraceful() {
        let bgContext = makeBackgroundContext(named: "truncatedLevel1")

        clearVisitedHistory()
        _ = Level1JsonReader(bgContext: bgContext,
                             fileName: "truncated",
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: true)
        waitForLoad(on: bgContext)

        #expect(organizationCount(in: bgContext) == 0)
    }

    // MARK: - Level 2

    // Garbage (non-JSON) input: with no parseable `club` object the reader records the expected diagnostic
    // and creates no organization.
    @Test("Level 2: garbage input is reported and creates nothing") func level2GarbageIsReported() {
        let bgContext = makeBackgroundContext(named: "garbageLevel2")

        let idPlus = OrganizationIdPlus(fullName: "Garbage Level 2 Club",
                                        town: "Nowhere",
                                        nickname: "garbage") // → loads garbage.level2.json

        let spy = makeIfDebugFatalErrorSpy()
        installIfDebugFatalErrorSpy(spy)
        defer { removeIfDebugFatalErrorSpy() }

        _ = Level2JsonReader(bgContext: bgContext,
                             organizationIdPlus: idPlus,
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: true)
        waitForLoad(on: bgContext)

        #expect(organizationCount(in: bgContext) == 0)
        #expect(spy.messages.contains { $0.contains("Cannot find `club` keyword") })
    }

    // A well-formed file whose `club` object is missing the required `idPlus`: checkIdPlus must report the
    // missing key and the reader must create no organization.
    @Test("Level 2: club missing idPlus is reported and creates nothing") func level2MissingIdPlus() {
        let bgContext = makeBackgroundContext(named: "level2MissingIdPlus")

        let idPlus = OrganizationIdPlus(fullName: "Missing IdPlus Club",
                                        town: "Nowhere",
                                        nickname: "missingIdPlus") // → loads missingIdPlus.level2.json

        let spy = makeIfDebugFatalErrorSpy()
        installIfDebugFatalErrorSpy(spy)
        defer { removeIfDebugFatalErrorSpy() }

        _ = Level2JsonReader(bgContext: bgContext,
                             organizationIdPlus: idPlus,
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: true)
        waitForLoad(on: bgContext)

        #expect(organizationCount(in: bgContext) == 0)
        #expect(spy.messages.contains { $0.contains("Cannot find `idPlus` keyword") })
    }

}
