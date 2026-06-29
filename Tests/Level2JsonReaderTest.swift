//
//  Level2JsonReaderTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 05/03/2025.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests the Level 2 JSON reader") struct Level2JsonReaderTests {

    private let testPersistenceController: PersistenceController
    private let viewContext: NSManagedObjectContext

    init () {
        // Each test gets its own private in-memory store, so the app's concurrent background
        // data-loading into PersistenceController.shared can't pollute the Expertise/PhotographerExpertise
        // counts below. Swift Testing creates a fresh suite instance (and thus a fresh init) per test, so
        // the store is effectively per-test — no deletion or cross-test isolation needed.
        testPersistenceController = PersistenceController(inMemory: true)
        viewContext = testPersistenceController.container.viewContext
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        // The empty store lacks several constant records the app seeds at launch; seed them here.
        // Providers create .club organizations that reference OrganizationType, so both are needed.
        // Must run on the main-queue viewContext (initConstants does a bare `save()`). See #749.
        Language.initConstants(context: viewContext)
        OrganizationType.initConstants(context: viewContext)
    }

    // Read TemplateMin.level2.json and check for parsing errors.
    // Clears all CoreData expertises. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse TemplateMin.level2.json") func templateMinParse() async {
        let bgContext = testPersistenceController.container.newBackgroundContext()
        bgContext.name = "TemplateMinTest"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        // Deletion must run on the main-queue viewContext: deleteCoreDataObjects is a @MainActor
        // main-thread API (its bare save() would trip _PFAssertSafeMultiThreadedAccess off-queue). See #749.
        Model.deleteCoreDataObjects(viewContext: viewContext, deletionScope: .expertisesOnly)
        #expect(Expertise.count(context: bgContext) == 0)

        // note that club TemplateMin may already be loaded
        // note that TemplateMinMembersProvider runs asynchronously (via bgContext.perform {})
        let randomTownForTesting = String.random(length: 10)

        _ = TemplateMinMembersProvider(bgContext: bgContext,
                                       isBeingTested: true,
                                       useOnlyInBundleFile: true,
                                       randomTownForTesting: randomTownForTesting)

        let idPlus = OrganizationIdPlus(fullName: "Template Club With Minimal Data",
                                        town: randomTownForTesting, // town to keep this separate from normal club data
                                        nickname: "TemplateMin")

        let predicateFormat: String = "town_ = %@" // avoid localization
        // Note that organizationType is not an identifying attribute.
        // This implies that you cannot have 2 organizations with the same Name and Town, but of a different type.
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [ randomTownForTesting ] )
        let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
        fetchRequest.predicate = predicate
        let organizations: [Organization] = (try? viewContext.fetch(fetchRequest)) ?? []

        #expect(Expertise.count(context: bgContext) == 0)
        #expect(PhotographerExpertise.count(context: bgContext) == 0)  // A club without PhotographerExpertises

        #expect(organizations.count == 1)
        if organizations.isEmpty == false {
            #expect(organizations[0].organizationType.organizationTypeName == OrganizationTypeEnum.club.rawValue)
            #expect(organizations[0].fullName == idPlus.fullName)
            #expect(organizations[0].town == idPlus.town)
            #expect(organizations[0].nickName == idPlus.nickname)
        }

    }

    // Read TemplateMax.level2.json and check for parsing errors
    // Clears all CoreData expertises. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse TemplateMax.level2.json") func templateMaxParse() async {
        let bgContext = testPersistenceController.container.newBackgroundContext()
        bgContext.name = "TemplateMaxTest"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        // Deletion must run on the main-queue viewContext: deleteCoreDataObjects is a @MainActor
        // main-thread API (its bare save() would trip _PFAssertSafeMultiThreadedAccess off-queue). See #749.
        Model.deleteCoreDataObjects(viewContext: viewContext, deletionScope: .expertisesOnly)
        #expect(Expertise.count(context: bgContext) == 0)

        // note that club TemplateMax may already be loaded
        // note that TemplateMaxMembersProvider runs asynchronously (via bgContext.perform {})
        let randomTownForTesting = String.random(length: 10)
        _ = TemplateMaxMembersProvider(bgContext: bgContext,
                                       isBeingTested: true,
                                       useOnlyInBundleFile: true,
                                       randomTownForTesting: randomTownForTesting)

        let idPlus = OrganizationIdPlus(fullName: "Template Club With Maximal Data",
                                        town: randomTownForTesting, // town to distinguish this from normal club data
                                        nickname: "TemplateMax")

        let predicateFormat: String = "town_ = %@" // avoid localization
        // Note that organizationType is not an identifying attribute.
        // This implies that you cannot have 2 organizations with the same Name and Town, but of a different type.
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [ randomTownForTesting ] )
        let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
        fetchRequest.predicate = predicate
        let organizations: [Organization] = (try? viewContext.fetch(fetchRequest)) ?? []

        #expect(Expertise.count(context: bgContext) == 5)
        #expect(PhotographerExpertise.count(context: bgContext, expertiseID: "Landscape") == 1)

        #expect(organizations.count == 1)
        if organizations.isEmpty == false {
            #expect(organizations[0].organizationType.organizationTypeName == OrganizationTypeEnum.club.rawValue)
            #expect(organizations[0].fullName == idPlus.fullName)
            #expect(organizations[0].town == idPlus.town)
            #expect(organizations[0].nickName == idPlus.nickname)
        }
    }

    // Read fgDeGender.level2.json and check for parsing errors
    // Clears all CoreData expertises. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse fgDeGender.level2.json") func fgDeGenderParse() async {
        let bgContext = testPersistenceController.container.newBackgroundContext()
        bgContext.name = "fgDeGenderTest"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        // Deletion must run on the main-queue viewContext: deleteCoreDataObjects is a @MainActor
        // main-thread API (its bare save() would trip _PFAssertSafeMultiThreadedAccess off-queue). See #749.
        Model.deleteCoreDataObjects(viewContext: viewContext, deletionScope: .expertisesOnly)
        #expect(Expertise.count(context: bgContext) == 0)

        // note that club fgDeGender may already be loaded
        // note that fgDeGenderMembersProvider runs asynchronously (via bgContext.perform {})
        let randomTownForTesting = String.random(length: 10)
        _ = FotogroepDeGenderMembersProvider(bgContext: bgContext, // The club has Expertises
                                             isBeingTested: true,
                                             useOnlyInBundleFile: true,
                                             randomTownForTesting: randomTownForTesting)

        let predicateFormat: String = "town_ = %@" // avoid localization
        // Note that organizationType is not an identifying attribute.
        // This implies that you cannot have 2 organizations with the same Name and Town, but of a different type.
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [ randomTownForTesting ] )
        let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
        fetchRequest.predicate = predicate
        let organizations: [Organization] = (try? viewContext.fetch(fetchRequest)) ?? []

        let idPlus = OrganizationIdPlus(fullName: "Fotogroep de Gender",
                                        town: randomTownForTesting, // town to distinguish this from normal club data
                                        nickname: "fgDeGender")

        #expect(organizations.count == 1)
        if organizations.isEmpty == false {
            #expect(organizations[0].organizationType.organizationTypeName == OrganizationTypeEnum.club.rawValue)
            #expect(organizations[0].fullName == idPlus.fullName)
            #expect(organizations[0].town == idPlus.town)
            #expect(organizations[0].nickName == idPlus.nickname)
            #expect(organizations[0].fotobondClubNumber?.id == 1620)
        }

        #expect(Expertise.count(context: bgContext) == 21)
        #expect(PhotographerExpertise.count(context: bgContext, expertiseID: "Minimal") == 3)
        #expect(PhotographerExpertise.count(context: bgContext) == 14)
    }

    // Read and check for expertise merging
    // Clears all CoreData expertises. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Load 2 clubs with expertise data for same photographer") func fgWaalreFgDeGender() async {
        let bgContext = testPersistenceController.container.newBackgroundContext()
        bgContext.name = "fgDeGenderTest"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        // Deletion must run on the main-queue viewContext: deleteCoreDataObjects is a @MainActor
        // main-thread API (its bare save() would trip _PFAssertSafeMultiThreadedAccess off-queue). See #749.
        Model.deleteCoreDataObjects(viewContext: viewContext, deletionScope: .expertisesOnly) // remove Expertises
        #expect(Expertise.count(context: bgContext) == 0)

        // note that club fgDeGender may already be loaded
        // note that fgDeGenderMembersProvider runs asynchronously (via bgContext.perform {})
        let randomTownForTestingG = String.random(length: 10)
        _ = FotogroepDeGenderMembersProvider(bgContext: bgContext,
                                             isBeingTested: true,
                                             useOnlyInBundleFile: true,
                                             randomTownForTesting: randomTownForTestingG)
        #expect(Expertise.count(context: bgContext) == 21)
        #expect(PhotographerExpertise.count(context: bgContext) == 14)

        let randomTownForTestingW = String.random(length: 10)
        _ = FotogroepWaalreMembersProvider(bgContext: bgContext,
                                           isBeingTested: true,
                                           useOnlyInBundleFile: true,
                                           randomTownForTesting: randomTownForTestingW)

        #expect(Expertise.count(context: bgContext) == 21)
        #expect(PhotographerExpertise.count(context: bgContext) == 42)
    }

}
