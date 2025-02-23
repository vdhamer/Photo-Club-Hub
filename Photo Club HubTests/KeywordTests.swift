//
// KeywordTests.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 21/02/2025.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests the Core Data Keyword class") struct KeywordTests {

    fileprivate let context: NSManagedObjectContext

    init () {
        context = PersistenceController.shared.container.viewContext
        Model.deleteAllCoreDataObjects()
    }

    @Test("Add a standard keyword") func addStandardKeyword() throws {
        let keyword = Keyword.findCreateUpdateStandard(context: context, id: "Test1")
        #expect(keyword.id == "Test1")
        #expect(keyword.isStandard == true)
        Keyword.save(context: context, keyword: keyword, create: true)
        #expect(Keyword.count(context: context, id: "Test1") == 1)
    }

    @Test("Add a non-standard keyword") func addNonStandardKeyword() throws {
        let keyword = Keyword.findCreateUpdateNonStandard(context: context, id: "Test2")
        #expect(keyword.id == "Test2")
        #expect(keyword.isStandard == false)
        Keyword.save(context: context, keyword: keyword, create: true)
        #expect(Keyword.count(context: context, id: "Test2") == 1)
    }

    @Test("Check capitalization of incoming ID strings") func checkIdCaplitalization() throws {
        let keyword = Keyword.findCreateUpdateStandard(context: context, id: "my Keyword")
        #expect(keyword.id == "My Keyword")
    }

    @Test("Avoid creating same keyword twice") func avoidDuplicateKeywords() {
        let id = "foobar".capitalized
        let keyword1 = Keyword.findCreateUpdateStandard(context: context, id: id)
        #expect(keyword1.isStandard == true)
        Keyword.save(context: context, keyword: keyword1, create: true)
        #expect(Keyword.count(context: context, id: id) == 1)

        let keyword2 = Keyword.findCreateUpdateNonStandard(context: context, id: id)
        Keyword.save(context: context, keyword: keyword1, create: true) // should not create a new record
        #expect(Keyword.count(context: context, id: id) == 1)

        #expect(keyword2.isStandard == false)
        #expect(keyword1.isStandard == false) // should not create a new record
    }

}
