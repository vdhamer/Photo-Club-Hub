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
    // Clears all CoreData expertises. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse XampleMin.level2.json") func xampleMinParse() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "XampleMin"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataExpertisesAndLanguages(viewContext: bgContext) // This test doesn't have Expertises
        #expect(Expertise.count(context: bgContext) == 0)

        // note that club XampleMin may already be loaded
        // note that XampleMinMembersProvider runs asynchronously (via bgContext.perform {})
        let randomTownForTesting = String.random(length: 10)

        _ = XampleMinMembersProvider(bgContext: bgContext,
                                     isBeingTested: true,
                                     useOnlyInBundleFile: true,
                                     randomTownForTesting: randomTownForTesting)

        let idPlus = OrganizationIdPlus(fullName: "Xample Club Min",
                                        town: randomTownForTesting, // town to keep this separate from normal club data
                                        nickname: "XampleMin")

        let predicateFormat: String = "town_ = %@" // avoid localization
        // Note that organizationType is not an identifying attribute.
        // This implies that you cannot have 2 organizations with the same Name and Town, but of a different type.
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [ randomTownForTesting ] )
        let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
        fetchRequest.predicate = predicate
        let organizations: [Organization] = (try? context.fetch(fetchRequest)) ?? []

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

    // Read XampleMax.level2.json and check for parsing errors
    // Clears all CoreData expertises. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse XampleMax.level2.json") func xampleMaxParse() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "XampleMax"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataExpertisesAndLanguages(viewContext: bgContext) // This test does have Expertises
        #expect(Expertise.count(context: bgContext) == 0)

        // note that club XampleMax may already be loaded
        // note that XampleMaxMembersProvider runs asynchronously (via bgContext.perform {})
        let randomTownForTesting = String.random(length: 10)
        _ = XampleMaxMembersProvider(bgContext: bgContext,
                                     isBeingTested: true,
                                     useOnlyInBundleFile: true,
                                     randomTownForTesting: randomTownForTesting)

        let idPlus = OrganizationIdPlus(fullName: "Xample Club With Maximal Data",
                                        town: randomTownForTesting, // town to distinguish this from normal club data
                                        nickname: "XampleMax")

        let predicateFormat: String = "town_ = %@" // avoid localization
        // Note that organizationType is not an identifying attribute.
        // This implies that you cannot have 2 organizations with the same Name and Town, but of a different type.
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [ randomTownForTesting ] )
        let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
        fetchRequest.predicate = predicate
        let organizations: [Organization] = (try? context.fetch(fetchRequest)) ?? []

        #expect(Expertise.count(context: bgContext) == 3)
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
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "fgDeGender"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataExpertisesAndLanguages(viewContext: bgContext)

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
        let organizations: [Organization] = (try? context.fetch(fetchRequest)) ?? []

        let idPlus = OrganizationIdPlus(fullName: "Fotogroep de Gender",
                                        town: randomTownForTesting, // town to distinguish this from normal club data
                                        nickname: "fgDeGender")

        #expect(organizations.count == 1)
        if organizations.isEmpty == false {
            #expect(organizations[0].organizationType.organizationTypeName == OrganizationTypeEnum.club.rawValue)
            #expect(organizations[0].fullName == idPlus.fullName)
            #expect(organizations[0].town == idPlus.town)
            #expect(organizations[0].nickName == idPlus.nickname)
            #expect(organizations[0].fotobondNumber == 1620)
        }

        #expect(Expertise.count(context: bgContext) == 21)
        #expect(PhotographerExpertise.count(context: bgContext, expertiseID: "Minimal") == 3)
        #expect(PhotographerExpertise.count(context: bgContext) == 14)
    }

    // Read and check for expertise merging
    // Clears all CoreData expertises. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Load 2 clubs with expertise data for same photographer") func fgWaalreFgDeGender() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "fgDeGender"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataExpertisesAndLanguages(viewContext: bgContext) // This test does have Expertises
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
