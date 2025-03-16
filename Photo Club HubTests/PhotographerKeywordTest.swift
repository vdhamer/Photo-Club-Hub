//
//  PhotographerKeywordTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 26/02/2025.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests the Core Data PhotographerKeyword class") struct PhotographerKeywordTests {

    fileprivate let context: NSManagedObjectContext
    fileprivate let photographer: Photographer

    init () {
        context = PersistenceController.shared.container.viewContext

        let personName = PersonName(givenName: String.random(length: 10), infixName: "", familyName: "UnitTestDummy")
        let optionalFields = PhotographerOptionalFields()
        photographer = Photographer.findCreateUpdate(context: context,
                                                     personName: personName,
                                                     optionalFields: optionalFields)
    }

    @Test("Create a random keyword for a random photographer") func addPhotographerKeyword() {

        let keywordID = String.random(length: 10).capitalized // internally keyword.id is capitalized
        let photographerKeyword = PhotographerKeyword.findCreateUpdate(
            context: context,
            photographer: photographer,
            keyword: Keyword.findCreateUpdateNonStandard(context: context, id: keywordID, name: [], usage: []))
        #expect(photographerKeyword.keyword.id == keywordID)
        #expect(photographerKeyword.photographer === photographer)
        #expect(photographerKeyword.photographer.givenName == photographer.givenName)
        #expect(photographerKeyword.photographer.infixName == photographer.infixName)
        #expect(photographerKeyword.photographer.familyName == photographer.familyName)
    }

    @Test("Attempt to create duplicate PhotographerKeyword") func duplicatePhotographerKeyword() {

        let keywordID = String.random(length: 10).capitalized // internally keyword.id is capitalized
        let photographerKeyword1 = PhotographerKeyword.findCreateUpdate(
            context: context,
            photographer: photographer,
            keyword: Keyword.findCreateUpdateNonStandard(context: context, id: keywordID, name: [], usage: []))
        #expect(photographerKeyword1.keyword.id == keywordID)
        #expect(photographerKeyword1.photographer === photographer)
        #expect(photographerKeyword1.photographer.givenName == photographer.givenName)
        #expect(photographerKeyword1.photographer.infixName == photographer.infixName)
        #expect(photographerKeyword1.photographer.familyName == photographer.familyName)
        PhotographerKeyword.save(context: context)

        let photographerKeyword2 = PhotographerKeyword.findCreateUpdate(
            context: context,
            photographer: photographer, // same photographer
            keyword: Keyword.findCreateUpdateNonStandard(context: context, id: keywordID,
                                                         name: [], usage: [])) // same keyword
        #expect(photographerKeyword2.keyword.id == keywordID)
        #expect(photographerKeyword2.photographer === photographer)
        #expect(photographerKeyword2.photographer.givenName == photographer.givenName)
        #expect(photographerKeyword2.photographer.infixName == photographer.infixName)
        #expect(photographerKeyword2.photographer.familyName == photographer.familyName)
        PhotographerKeyword.save(context: context)

        #expect(photographerKeyword1 == photographerKeyword2)
        #expect(PhotographerKeyword.count(context: context, keywordID: keywordID, photographer: photographer) == 1)
    }

}
