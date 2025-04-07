//
//  Level0JsonReaderTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 13/03/2025.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests the Level 0 JSON reader") struct Level0JsonReaderTests {

    fileprivate let context: NSManagedObjectContext

    init () {
        context = PersistenceController.shared.container.viewContext
    }

    // Read root.level0.json and check for parsing errors.
    // Clears all CoreData keywords. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse empty.level0.json") func emptyLevel0Parse() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "EmptyLevel0"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataKeywordsLanguages(context: bgContext)
        #expect(Keyword.count(context: bgContext) == 0)
        #expect(LocalizedKeyword.count(context: bgContext) == 0)
        #expect(PhotographerKeyword.count(context: bgContext) == 0)

        _ = Level0JsonReader(bgContext: bgContext, // read root.Level0.json file
                             useOnlyFile: false,
                             overrulingDataSourceFile: "empty")
        #expect(Keyword.count(context: bgContext) == 0)
        #expect(LocalizedKeyword.count(context: bgContext) == 0)
        #expect(PhotographerKeyword.count(context: bgContext) == 0)
    }

    // Read abstract.level0.json.
    // Clears all CoreData keywords. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse abstractKeyword.level0.json") func abstractKeywordLevel0Parse() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "AbstractKeywordLevel0"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataKeywordsLanguages(context: bgContext)
        #expect(Keyword.count(context: bgContext) == 0) // returns 3 instead of zero, why??
        #expect(PhotographerKeyword.count(context: bgContext) == 0) // returns 3 instead of zero, why??
        #expect(LocalizedKeyword.count(context: bgContext) == 0)

        bgContext.performAndWait {
            _ = Level0JsonReader(bgContext: bgContext, // read root.Level0.json file
                                 useOnlyFile: false,
                                 overrulingDataSourceFile: "abstractKeyword")
            try? bgContext.save()
        }
        #expect(Keyword.count(context: bgContext) == 1)
        #expect(PhotographerKeyword.count(context: bgContext) == 0)
        #expect(LocalizedKeyword.count(context: bgContext) == 4)
   }

    // Read root.level0.json and check for parsing errors.
    // Clears all CoreData keywords. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse root.level0.json") func rootLevel0Parse() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "RootLevel0"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataKeywordsLanguages(context: bgContext) // This test doesn't have Keywords
        #expect(Keyword.count(context: bgContext) == 0)

        _ = Level0JsonReader(bgContext: bgContext, // read root.Level0.json file
                             useOnlyFile: false)
        #expect(Keyword.count(context: bgContext) == 13)
    }

    // Read language.level0.json.
    // Clears all CoreData languages. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse language.level0.json") func languageLevel0Parse() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "LanguageLevel0"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataKeywordsLanguages(context: bgContext)
        #expect(Language.count(context: bgContext, isoCode: "UR") == 0)
        #expect(LocalizedRemark.count(context: bgContext) == 0)
        #expect(LocalizedKeyword.count(context: bgContext) == 0)

        _ = Level0JsonReader(bgContext: bgContext, // read root.Level0.json file
                             useOnlyFile: false,
                             overrulingDataSourceFile: "language")

        #expect(Language.count(context: bgContext, isoCode: "UR") == 1)
        #expect(LocalizedRemark.count(context: bgContext) == 0)
        #expect(LocalizedKeyword.count(context: bgContext) == 0)
    }

}
