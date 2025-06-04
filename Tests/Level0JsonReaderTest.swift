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
                             fileName: "empty", isInTestBundle: true,
                             useOnlyInBundleFile: false)
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
                                 fileName: "abstractKeyword", isInTestBundle: true,
                                 useOnlyInBundleFile: false)
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
                             fileName: "root", isInTestBundle: false,
                             useOnlyInBundleFile: false)
        #expect(Keyword.count(context: bgContext) == 21)
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
                             fileName: "language", isInTestBundle: true,
                             useOnlyInBundleFile: false)

        #expect(Language.count(context: bgContext, isoCode: "UR") == 1)
        #expect(LocalizedRemark.count(context: bgContext) == 0)
        #expect(LocalizedKeyword.count(context: bgContext) == 0)
    }

    // Read language.level0.json.
    // Clears all CoreData languages. Runs on background thread, adding bunch of extra complexity ;-(
    @Test("Parse languages.level0.json") func languagesLevel0Parse() async {
        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = "LanguagesLevel0"
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true

        Model.deleteCoreDataKeywordsLanguages(context: bgContext)
        #expect(Language.count(context: bgContext, isoCode: "UR") == 0)
        #expect(LocalizedRemark.count(context: bgContext) == 0)
        #expect(LocalizedKeyword.count(context: bgContext) == 0)

        _ = Level0JsonReader(bgContext: bgContext, // read root.Level0.json file
                             fileName: "languages", isInTestBundle: true,
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
        #expect(LocalizedKeyword.count(context: bgContext) == 0)
    }

}
