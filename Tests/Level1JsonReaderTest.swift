//
//  Level1JsonReaderTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 30/06/2026.
//

import Testing // for macros like @Test
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

private let isBeingTested = true

// Level1History (used by the Include machinery) is annotated with @available(iOS 18, macOS 15, *), and
// the app supports iOS 17.x. The include test below is therefore gated with an `.enabled(if:)` condition
// trait so that on iOS 17 it is reported as *skipped* rather than as a silent pass. (Same trick as in
// Level1HistoryTest.swift; Swift Testing's @Test macro cannot be attached to @available declarations.)
// The in-body `#available` guard is still needed to satisfy the compiler; it is unreachable when enabled.
private let level1HistoryAvailable: Bool = {
    if #available(iOS 18, macOS 15, *) { true } else { false }
}()

// The suite is @MainActor and its first three tests are synchronous (they never suspend), which prevents
// their bodies from interleaving. That is load-bearing beyond Core Data isolation: those tests share the
// process-global Level1JsonReader.level1History, and two of them load the same file ("clubTemplates") —
// if their bodies could interleave, one test's load could mark the file "visited" mid-way through the
// other's, firing the duplicate-file ifDebugFatalError. So do NOT migrate them to `await load(...)` until
// level1History is injectable (follow-up in #760). includeLoadsIntoInjectedStore() does suspend, but its
// data files are unique to that test, so it cannot collide. Isolation from the app's concurrent background
// loading comes from the use of a per-test IN-MEMORY store, not from execution order.
@MainActor @Suite("Tests the Level 1 JSON reader") struct Level1JsonReaderTests {

    // MARK: - Init

    private let testPersistenceController: PersistenceController
    private let viewContext: NSManagedObjectContext

    init () {
        // Each test gets its own private in-memory store so the app's concurrent background data-loading
        // into PersistenceController.shared cannot pollute the Organization counts below. Swift Testing
        // creates a fresh suite instance (and thus a fresh init) per test, so the store is effectively
        // per-test — no deletion or cross-test isolation needed.
        testPersistenceController = PersistenceController(inMemory: true) // inMemory is important for isolation
        viewContext = testPersistenceController.container.viewContext
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        // The empty store lacks the constant records the app inserts at launch; so we insert them here.
        // Level1 organizations reference OrganizationType, so OrganizationType (and Language) must exist first.
        // Must run on the main-queue viewContext (initConstants does a bare save()). See #749.
        Language.initConstants(context: viewContext)
        OrganizationType.initConstants(context: viewContext)
    }

    // Makes a background context wired up the same way the app's Level 1 loader configures one.
    private func makeBackgroundContext(named name: String) -> NSManagedObjectContext {
        let bgContext = testPersistenceController.container.newBackgroundContext()
        bgContext.name = name
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true
        return bgContext
    }

    // The visited-file guard is a process-wide singleton shared with the app's background loading.
    // Clearing it before each load ensures the requested file is actually parsed rather than being
    // skipped because some other code path already marked it visited. (??)
    private func clearVisitedHistory() {
        if #available(iOS 18, macOS 15, *) {
            Level1JsonReader.level1History.clear()
        }
    }

    // FetchAndProcessFile does its work asynchronously on `bgContext.perform { }`.
    // For a file without Includes the entire parse-and-save runs inside that single block
    // on the context's serial queue, so enqueueing an empty `performAndWait` afterwards acts as a barrier:
    // it cannot run until the load block has finished.
    // (Files WITH includes spawn further work on other contexts — includeLoadsIntoInjectedStore()
    // below covers that case by awaiting Level1JsonReader.load(...) instead.)
    private func waitForLoad(on bgContext: NSManagedObjectContext) {
        bgContext.performAndWait { }
    }

    // Fetches every Organization currently in stock in the in-memory store.
    private func allOrganizations() -> [Organization] {
        let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
        return (try? viewContext.fetch(fetchRequest)) ?? []
    }

    // MARK: - Tests

    // Read clubTemplates.level1.json (2 clubs, no museums, no includes) and verify both clubs land
    // with the right identity, and that the right club's optional fotobondNumber is parsed.
    @Test("Parse clubTemplates.level1.json") func clubTemplatesParse() {
        let bgContext = makeBackgroundContext(named: "clubTemplatesTest")
        #expect(allOrganizations().isEmpty) // fresh store: initConstants doesn't insert Organization

        clearVisitedHistory()
        _ = Level1JsonReader(bgContext: bgContext,
                             fileName: "clubTemplates",
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: true)
        waitForLoad(on: bgContext)

        let organizations = allOrganizations()
        #expect(organizations.count == 2) // the 2 organizations in the JSON file
        #expect(organizations.allSatisfy { organization in // both organizations are Clubs
            organization.organizationType.organizationTypeName == OrganizationTypeEnum.club.rawValue
        })

        // The "maximal" club has a Dutch Fotobond number; verify this number survives a round-trip.
        let templateMax = organizations.first { $0.nickName == "TemplateMax" }
        #expect(templateMax != nil)
        #expect(templateMax?.fullName == "Template Club With Maximal Data")
        #expect(templateMax?.town == "Rotterdam")
        #expect(templateMax?.fotobondClubNumber?.id == 9999)

        // The "minimal" club has only a level2URL; it must have no Fotobond number.
        let templateMin = organizations.first { $0.nickName == "TemplateMin" }
        #expect(templateMin != nil)
        #expect(templateMin?.town == "Amsterdam")
        #expect(templateMin?.fotobondClubNumber?.id == nil)
    }

    // Read museumsTest.level1.json (2 museums, no clubs, no includes)
    // and verify that the reader correctly populates Organizations of type .museum.
    @Test("Parse museumsTest.level1.json") func museumsGBParse() {
        let bgContext = makeBackgroundContext(named: "museumsTest")
        #expect(allOrganizations().isEmpty)

        clearVisitedHistory()
        _ = Level1JsonReader(bgContext: bgContext,
                             fileName: "museumsTest",
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: true)
        waitForLoad(on: bgContext)

        let organizations = allOrganizations()
        #expect(organizations.count == 2) // exactly the 2 museums in the file
        #expect(organizations.allSatisfy {
            $0.organizationType.organizationTypeName == OrganizationTypeEnum.museum.rawValue
        })

        let vaOrganization = organizations.first { $0.nickName == "V&A London" }
        #expect(vaOrganization != nil)
        #expect(vaOrganization?.fullName == "The Victoria & Albert Museum")
        #expect(vaOrganization?.town == "London")
    }

    // Loading the same file twice must not create duplicate Organizations: findCreateUpdate
    // matches on idPlus (name + town), so the second load updates rather than duplicates.
    @Test("Reloading the same file is idempotent") func reloadIsIdempotent() {
        let bgContext = makeBackgroundContext(named: "clubTemplatesReloadTest")

        clearVisitedHistory()
        _ = Level1JsonReader(bgContext: bgContext,
                             fileName: "clubTemplates",
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: true)
        waitForLoad(on: bgContext)
        #expect(allOrganizations().count == 2)

        // Clear the visited guard so the second load is actually processed (not short-circuited),
        // which is what exercises findCreateUpdate's de-duplication.
        clearVisitedHistory()
        _ = Level1JsonReader(bgContext: bgContext,
                             fileName: "clubTemplates",
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: true)
        waitForLoad(on: bgContext)
        #expect(allOrganizations().count == 2) // still 2, not 4
    }

    // Read IncludeParent.level1.json, which has no organizations of its own but includes
    // IncludeChild.level1.json (a leaf with one uniquely-named club). This verifies that the
    // `usedContainer:` seam routes an included file's load into this test's in-memory store.
    //
    // These two test data files exist only for this test. That matters:
    //   * The include tree is ACYCLIC — the recursion test data files  (recursionA/recursionB) form a
    //     deliberate cycle, and the loop guard must handle the cycle with ifDebugFatalError, i.e. a hard
    //     `fatalError` in DEBUG (test) builds. Cycle *detection* is covered safely by Level1HistoryTests.
    //   * The file names are ones the APP never loads, so they can't collide with the app's concurrent
    //     background loading in the shared (global) level1History — a collision there also triggers a fatalError
    //     as a "duplicate file in Include tree".
    //
    // Included files load asynchronously on contexts this test doesn't own, so the test awaits
    // Level1JsonReader.load(...), which returns only after the whole Include tree — including the
    // IncludeChild save — has completed (issue #760). The `await` IS the happens-before guarantee; no
    // NotificationCenter spying, no unstructured Task {}, no Task.yield() timing hacks.
    @Test("An included file is loaded into the injected store",
          .enabled(if: level1HistoryAvailable, "Level1History requires iOS 18 / macOS 15"))
    func includeLoadsIntoInjectedStore() async {
        guard #available(iOS 18, macOS 15, *) else { return } // compiler-only; unreachable when enabled
        clearVisitedHistory()

        let bgContext = makeBackgroundContext(named: "IncludeParentTest")

        await Level1JsonReader.load(bgContext: bgContext,
                                    fileName: "IncludeParent",
                                    isBeingTested: isBeingTested,
                                    useOnlyInBundleFile: true,
                                    usedContainer: testPersistenceController.container)
        // ^ usedContainer routes the included files' loads into the test's in-memory store

        // The club from the *included* IncludeChild.level1.json must now be in the injected store.
        let club = allOrganizations().first { $0.nickName == "IncludeChild" }
        #expect(club != nil)
        #expect(club?.fullName == "Include Child Club")
        #expect(club?.town == "Test Valley")
    }

}
