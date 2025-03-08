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
    }

    @Test("Add a standard keyword") func addStandardKeyword() throws {
        let keywordID = String.random(length: 10).capitalized
        let keyword = Keyword.findCreateUpdateStandard(context: context, id: keywordID)
        #expect(keyword.id == keywordID)
        #expect(keyword.isStandard == true)
        Keyword.save(context: context, errorText: "Error saving keyword \"\(keywordID)\"")
        #expect(Keyword.count(context: context, keywordID: keywordID) == 1)
    }

    @Test("Add a non-standard keyword") func addNonStandardKeyword() throws {
        let keywordID = String.random(length: 10).capitalized
        let keyword = Keyword.findCreateUpdateNonStandard(context: context, id: keywordID)
        #expect(keyword.id == keywordID)
        #expect(keyword.isStandard == false)
        Keyword.save(context: context, errorText: "Error saving keyword \"\(keywordID)\"")
        #expect(Keyword.count(context: context, keywordID: keywordID) == 1)
    }

    @Test("Check capitalization of incoming ID strings") func checkIdCaplitalization() throws {
        let keywordID = "a " + String.random(length: 8).capitalized
        let keyword = Keyword.findCreateUpdateStandard(context: context, id: keywordID.capitalized)
        #expect(keyword.id == keywordID.capitalized)
    }

    @Test("Avoid creating same keyword twice") func avoidDuplicateKeywords() {
        let id = String.random(length: 10).capitalized
        let keyword1 = Keyword.findCreateUpdateStandard(context: context, id: id)
        #expect(keyword1.isStandard == true)
        Keyword.save(context: context, errorText: "Error saving keyword \"\(id)\"")
        #expect(Keyword.count(context: context, keywordID: id) == 1)
        Keyword.save(context: context, errorText: "Error saving keyword \"\(id)\"") // shouldn't create a new record

        let keyword2 = Keyword.findCreateUpdateNonStandard(context: context, id: id)
        #expect(Keyword.count(context: context, keywordID: id) == 1)
        #expect(keyword2.isStandard == false)

        #expect(keyword1.isStandard == false) // should not create a new record
    }

}
