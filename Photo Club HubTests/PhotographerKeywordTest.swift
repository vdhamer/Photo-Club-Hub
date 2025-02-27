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

        let personName = PersonName(givenName: "Jan", infixName: "", familyName: randomString(10))
        let optionalFields = PhotographerOptionalFields()
        photographer = Photographer.findCreateUpdate(context: context,
                                                     personName: personName,
                                                     optionalFields: optionalFields)
    }

    @Test("Create a random keyword for a random photographer") func addPhotographerKeyword() {

        let keywordID = randomString(10).capitalized // internally keyword.id is capitalized
        let photographerKeyword = PhotographerKeyword.findCreateUpdate(
            context: context,
            photographer: photographer,
            keyword: Keyword.findCreateUpdateNonStandard(context: context, id: keywordID))
        #expect(photographerKeyword.keyword.id == keywordID)
        #expect(photographerKeyword.photographer === photographer)
        #expect(photographerKeyword.photographer.givenName == "Jan")
        #expect(photographerKeyword.photographer.infixName == "")
        #expect(photographerKeyword.photographer.familyName == photographer.familyName)
    }

    @Test("Attempt to create duplicate PhotographerKeyword") func duplicatePhotographerKeyword() {

        let keywordID = randomString(10).capitalized // internally keyword.id is capitalized
        let photographerKeyword1 = PhotographerKeyword.findCreateUpdate(
            context: context,
            photographer: photographer,
            keyword: Keyword.findCreateUpdateNonStandard(context: context, id: keywordID))
        #expect(photographerKeyword1.keyword.id == keywordID)
        #expect(photographerKeyword1.photographer === photographer)
        #expect(photographerKeyword1.photographer.givenName == "Jan")
        #expect(photographerKeyword1.photographer.infixName == "")
        #expect(photographerKeyword1.photographer.familyName == photographer.familyName)
        PhotographerKeyword.save(context: context)

        let photographerKeyword2 = PhotographerKeyword.findCreateUpdate(
            context: context,
            photographer: photographer, // same photographer
            keyword: Keyword.findCreateUpdateNonStandard(context: context, id: keywordID)) // same keyword
        #expect(photographerKeyword2.keyword.id == keywordID)
        #expect(photographerKeyword2.photographer === photographer)
        #expect(photographerKeyword2.photographer.givenName == "Jan")
        #expect(photographerKeyword2.photographer.infixName == "")
        #expect(photographerKeyword2.photographer.familyName == photographer.familyName)
        PhotographerKeyword.save(context: context)

        #expect(photographerKeyword1 == photographerKeyword2)
        #expect(PhotographerKeyword.count(context: context, keywordID: keywordID, photographer: photographer) == 1)
    }

}

private func randomString(_ length: Int) -> String {
   let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
   let randomString = (0..<length).map { _ in String(letters.randomElement()!) }.reduce("", +)
   return randomString
}
