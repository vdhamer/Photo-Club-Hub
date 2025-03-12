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

    fileprivate let context: NSManagedObjectContext

    init () {
        context = PersistenceController.shared.container.viewContext
    }

    // Read XampleMin.level2.json and check for parsing errors.
    // Clears entire CoreData database. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse XampleMin.level2.json") func xampleMinParse() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "XampleMin"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataKeywords(context: bgContext) // This test doesn't have Keywords
        #expect(Keyword.count(context: bgContext) == 0)

        // note that club XampleMin may already be loaded
        // note that XampleMinMembersProvider runs asynchronously (via bgContext.perform {})
        let randomTown = String.random(length: 10)
        _ = XampleMinMembersProvider(bgContext: bgContext, synchronousWithRandomTown: true, randomTown: randomTown)

        let idPlus = OrganizationIdPlus(fullName: "Xample Club Min",
                                        town: randomTown, // unique town to keep this separate from normal loading
                                        nickname: "XampleMin")

        let predicateFormat: String = "town_ = %@" // avoid localization
        // Note that organizationType is not an identifying attribute.
        // This implies that you cannot have 2 organizations with the same Name and Town, but of a different type.
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [ randomTown ] )
        let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
        fetchRequest.predicate = predicate
        let organizations: [Organization] = (try? context.fetch(fetchRequest)) ?? []

        #expect(Keyword.count(context: bgContext) == 0)

        #expect(organizations.count == 1)
        if organizations.isEmpty == false {
            #expect(organizations[0].organizationType.organizationTypeName == OrganizationTypeEnum.club.rawValue)
            #expect(organizations[0].fullName == idPlus.fullName)
            #expect(organizations[0].town == idPlus.town)
            #expect(organizations[0].nickname == idPlus.nickname)
        }

    }

    // Read XampleMax.level2.json and check for parsing errors
    // Clears entire CoreData database. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse XampleMax.level2.json") func xampleMaxParse() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "XampleMax"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataKeywords(context: bgContext) // This test does have Keywords
        #expect(Keyword.count(context: bgContext) == 0)

        // note that club XampleMax may already be loaded
        // note that XampleMaxMembersProvider runs asynchronously (via bgContext.perform {})
        let randomTown = String.random(length: 10)
        _ = XampleMaxMembersProvider(bgContext: bgContext, synchronousWithRandomTown: true, randomTown: randomTown)

        let idPlus = OrganizationIdPlus(fullName: "Xample Club Max",
                                        town: randomTown, // unique town to keep this separate from normal loading
                                        nickname: "XampleMax")

        let predicateFormat: String = "town_ = %@" // avoid localization
        // Note that organizationType is not an identifying attribute.
        // This implies that you cannot have 2 organizations with the same Name and Town, but of a different type.
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [ randomTown ] )
        let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
        fetchRequest.predicate = predicate
        let organizations: [Organization] = (try? context.fetch(fetchRequest)) ?? []

        #expect(Keyword.count(context: bgContext) == 3)
        #expect(PhotographerKeyword.count(context: bgContext, keywordID: "Landscape") == 1)

        #expect(organizations.count == 1)
        if organizations.isEmpty == false {
            #expect(organizations[0].organizationType.organizationTypeName == OrganizationTypeEnum.club.rawValue)
            #expect(organizations[0].fullName == idPlus.fullName)
            #expect(organizations[0].town == idPlus.town)
            #expect(organizations[0].nickname == idPlus.nickname)
        }
    }

    // Read fgDeGender.level2.json and check for parsing errors
    // Clears entire CoreData database. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse fgDeGender.level2.json") func fgDeGenderParse() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "fgDeGender"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataKeywords(context: bgContext) // This test does have Keywords

        // note that club fgDeGender may already be loaded
        // note that fgDeGenderMembersProvider runs asynchronously (via bgContext.perform {})
        let randomTown = String.random(length: 10)
        _ = FotogroepDeGenderMembersProvider(bgContext: bgContext,
                                             synchronousWithRandomTown: true,
                                             randomTown: randomTown)

        let predicateFormat: String = "town_ = %@" // avoid localization
        // Note that organizationType is not an identifying attribute.
        // This implies that you cannot have 2 organizations with the same Name and Town, but of a different type.
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [ randomTown ] )
        let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
        fetchRequest.predicate = predicate
        let organizations: [Organization] = (try? context.fetch(fetchRequest)) ?? []

        let idPlus = OrganizationIdPlus(fullName: "Fotogroep de Gender",
                                        town: randomTown, // unique town to keep this separate from normal loading
                                        nickname: "fgDeGender")

        #expect(organizations.count == 1)
        if organizations.isEmpty == false {
            #expect(organizations[0].organizationType.organizationTypeName == OrganizationTypeEnum.club.rawValue)
            #expect(organizations[0].fullName == idPlus.fullName)
            #expect(organizations[0].town == idPlus.town)
            #expect(organizations[0].nickname == idPlus.nickname)
            #expect(organizations[0].fotobondNumber == 1620)
        }

        #expect(Keyword.count(context: bgContext) == 2)
        #expect(PhotographerKeyword.count(context: bgContext, keywordID: "Minimal") == 1)
        #expect(PhotographerKeyword.count(context: bgContext) == 2)
    }

    // Read fgDeGender.level2.json and check for parsing errors
    // Clears entire CoreData database. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Load 2 clubs with keyword data for same photographer") func fgWaalreFgDeGender() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "fgDeGender"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataKeywords(context: bgContext) // This test does have Keywords

        // note that club fgDeGender may already be loaded
        // note that fgDeGenderMembersProvider runs asynchronously (via bgContext.perform {})
        let randomTownG = String.random(length: 10)
        _ = FotogroepDeGenderMembersProvider(bgContext: bgContext,
                                             synchronousWithRandomTown: true,
                                             randomTown: randomTownG)
        let randomTownW = String.random(length: 10)
        _ = FotogroepWaalreMembersProvider(bgContext: bgContext,
                                           synchronousWithRandomTown: true,
                                           randomTown: randomTownW)

        #expect(Keyword.count(context: bgContext) == 3)
    }

}
