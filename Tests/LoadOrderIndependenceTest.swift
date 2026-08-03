//
//  LoadOrderIndependenceTest.swift
//  Photo Club HubTests
//
//  Created by Claude Code (guided by Peter van den Hamer) on 02/08/2026.
//

import Testing
import Foundation
import CoreData // for NSManagedObjectContext
import Photo_Club_Hub_Data // for Level0JsonReader, Level2JsonReader, Expertise, OrganizationIdPlus

// #769 step 8(a), re-scoped.
//
// The original wording was "app startup loads Level 0 before Level 2", but no such ordering exists:
// loadClubsAndMembers() hands every loader its own newBackgroundContext() and each returns immediately,
// so Level 0, Level 1 and the 14 Level 2 loads run concurrently. What actually makes that safe is that
// the outcome does not depend on the order: Level 2 creates unknown expertises through
// findCreateUpdateUndefSupported, which passes `isSupported: nil` rather than false, so a later Level 0
// can still promote them to supported. This test pins that property.
//
// SCOPE: this is an *order-independence* test, not a concurrency-safety test. Both arms below run
// sequentially. It does not exercise two contexts interleaving inside a single find-then-create window;
// that is the job of the model's uniqueness constraints plus a conflict-resolving merge policy, and of
// initConstants() pre-creating the most contended rows. Please do not read a pass here as proof that
// concurrent loading is race-free.
@MainActor
@Suite("Tests that Level 0 / Level 2 load order does not change the result")
struct LoadOrderIndependenceTests {

    // The bundled TemplateMax.level2.json club. Its two members between them reference the expertises
    // Experimental, Street, Landscape, Travel and Minimal — all five of which root.level0.json declares,
    // so the Level-2-first arm really does exercise create-as-temporary followed by promotion.
    private static let templateMax = OrganizationIdPlus(fullName: "Template Club With Maximal Data",
                                                        town: "Rotterdam",
                                                        nickname: "TemplateMax")

    private func makeContext() -> NSManagedObjectContext {
        // A private in-memory store per arm, so the two orderings cannot see each other's records.
        let context = PersistenceController(inMemory: true).container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }

    // useOnlyInBundleFile avoids the network so the test is deterministic; isBeingTested stays false so
    // the production root.level0.json / TemplateMax.level2.json are used rather than test variants.
    private func loadLevel0(into context: NSManagedObjectContext) async {
        await Level0JsonReader.load(bgContext: context,
                                    isBeingTested: false,
                                    useOnlyInBundleFile: true)
    }

    private func loadLevel2(into context: NSManagedObjectContext) async {
        // No need to pre-create the club: readRootLevel2Json calls Organization.findCreateUpdate itself.
        // (The *MembersProvider types create it first only so they can log the club name beforehand.)
        // Avoiding that call also keeps SwiftyJSON out of the test target: the default arguments of
        // OrganizationOptionalFields.init reference SwiftyJSON.JSON, and default arguments are emitted
        // in the caller, so calling it here would require the test target to link SwiftyJSON too.
        await Level2JsonReader.load(bgContext: context,
                                    organizationIdPlus: Self.templateMax,
                                    isBeingTested: false,
                                    useOnlyInBundleFile: true)
    }

    // Maps expertise id (lowercased, so canonicalCase differences cannot mask a mismatch) to isSupported.
    private func expertiseSupport(in context: NSManagedObjectContext) async -> [String: Bool] {
        await context.perform {
            let expertises = (try? context.fetch(Expertise.fetchRequest())) ?? []
            return Dictionary(expertises.map { ($0.id.lowercased(), $0.isSupported) },
                              uniquingKeysWith: { first, _ in first })
        }
    }

    @Test("Loading Level 0 then Level 2 gives the same expertise state as the reverse")
    func loadOrderDoesNotChangeExpertiseState() async {
        let level0First = makeContext()
        await loadLevel0(into: level0First)
        await loadLevel2(into: level0First)

        let level2First = makeContext()
        await loadLevel2(into: level2First)
        await loadLevel0(into: level2First)

        let supportA = await expertiseSupport(in: level0First)
        let supportB = await expertiseSupport(in: level2First)

        #expect(!supportA.isEmpty, "precondition: the Level 0 / Level 2 loads produced no expertises at all")
        #expect(supportA == supportB, """
                Expertise state depends on load order.
                Only in "Level 0 first": \(supportA.filter { supportB[$0.key] != $0.value })
                Only in "Level 2 first": \(supportB.filter { supportA[$0.key] != $0.value })
                """)

        // The expertises TemplateMax's members reference are declared by Level 0, so they must end up
        // supported whichever order ran. If Level 2 ever passed `isSupported: false` instead of nil,
        // the Level-2-first arm would leave these stuck as temporary and this would catch it.
        for id in ["experimental", "street", "landscape", "travel", "minimal"] {
            #expect(supportA[id] == true, "\(id) not supported when Level 0 loaded first")
            #expect(supportB[id] == true, "\(id) not supported when Level 2 loaded first")
        }
    }
}
