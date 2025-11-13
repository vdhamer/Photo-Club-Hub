//
//  Level0JsonReaderTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 13/03/2025.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

private let isBeingTested = true

@MainActor @Suite("Tests the Level 0 JSON reader") struct Level0JsonReaderTests {

    private let context: NSManagedObjectContext

    init () {
        context = PersistenceController.shared.container.viewContext
    }

    // Read root.level0.json and check for parsing errors.
    // Clears all CoreData expertises. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse empty.level0.json") func emptyLevel0Parse() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "EmptyLevel0"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataExpertisesAndLanguages(viewContext: bgContext)
        #expect(Expertise.count(context: bgContext) == 0)
        #expect(LocalizedExpertise.count(context: bgContext) == 0)
        #expect(PhotographerExpertise.count(context: bgContext) == 0)

        _ = Level0JsonReader(bgContext: bgContext, // read root.Level0.json file
                             fileName: "empty",
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: false)
        #expect(Expertise.count(context: bgContext) == 0)
        #expect(LocalizedExpertise.count(context: bgContext) == 0)
        #expect(PhotographerExpertise.count(context: bgContext) == 0)
    }

    // Read abstract.level0.json.
    // Clears all CoreData expertises. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse abstractExpertise.level0.json") func abstractExpertiseLevel0Parse() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "AbstractExpertiseLevel0"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataExpertisesAndLanguages(viewContext: bgContext)
        #expect(Expertise.count(context: bgContext) == 0) // returns 3 instead of zero, why??
        #expect(LocalizedExpertise.count(context: bgContext) == 0)
        #expect(PhotographerExpertise.count(context: bgContext) == 0) // returns 3 instead of zero, why??

        bgContext.performAndWait {
            _ = Level0JsonReader(bgContext: bgContext, // read root.Level0.json file
                                 fileName: "abstractExpertise",
                                 isBeingTested: isBeingTested,
                                 useOnlyInBundleFile: false)
            try? bgContext.save()
        }
        #expect(Expertise.count(context: bgContext) == 1)
        #expect(LocalizedExpertise.count(context: bgContext) == 4)
        #expect(PhotographerExpertise.count(context: bgContext) == 0)
   }

    // Read root.level0.json and check for parsing errors.
    // Clears all CoreData expertises. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse root.level0.json") func rootLevel0Parse() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "RootLevel0"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataExpertisesAndLanguages(viewContext: bgContext) // This test doesn't have Expertises
        #expect(Expertise.count(context: bgContext) == 0)

        _ = Level0JsonReader(bgContext: bgContext, // read root.Level0.json file
                             fileName: "root",
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: false)
        #expect(Expertise.count(context: bgContext) == 25)
    }

    // Read language.level0.json.
    // Clears all CoreData languages. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse language.level0.json") func languageLevel0Parse() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "LanguageLevel0"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataExpertisesAndLanguages(viewContext: bgContext)
        #expect(Language.count(context: bgContext, isoCode: "UR") == 0)
        #expect(LocalizedRemark.count(context: bgContext) == 0)
        #expect(LocalizedExpertise.count(context: bgContext) == 0)

        _ = Level0JsonReader(bgContext: bgContext, // read root.Level0.json file
                             fileName: "language",
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: false)

        #expect(Language.count(context: bgContext, isoCode: "UR") == 1)
        #expect(LocalizedRemark.count(context: bgContext) == 0)
        #expect(LocalizedExpertise.count(context: bgContext) == 0)
    }

    // Read language.level0.json.
    // Clears all CoreData languages. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse languages.level0.json") func languagesLevel0Parse() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "LanguagesLevel0"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataExpertisesAndLanguages(viewContext: bgContext)
        #expect(Language.count(context: bgContext, isoCode: "UR") == 0)
        #expect(LocalizedRemark.count(context: bgContext) == 0)
        #expect(LocalizedExpertise.count(context: bgContext) == 0)

        _ = Level0JsonReader(bgContext: bgContext, // read root.Level0.json file
                             fileName: "languages",
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: false)

        #expect(Language.count(context: bgContext, isoCode: "EN") == 1)
        #expect(Language.count(context: bgContext, isoCode: "NL") == 1)
        #expect(Language.count(context: bgContext, isoCode: "DE") == 1)
        #expect(Language.count(context: bgContext, isoCode: "UR") == 1)
        #expect(Language.count(context: bgContext, isoCode: "UK") == 1)
        #expect(Language.count(context: bgContext, isoCode: "FR") == 1) // from initConstants
        #expect(Language.count(context: bgContext, isoCode: "ES") == 1) // from initConstants
        #expect(Language.count(context: bgContext, isoCode: "PL") == 1) // from initConstants
        #expect(Language.count(context: bgContext, isoCode: "XX") == 0)
        #expect(Language.count(context: bgContext) == 8)
        #expect(LocalizedRemark.count(context: bgContext) == 0)
        #expect(LocalizedExpertise.count(context: bgContext) == 0)
    }

}
