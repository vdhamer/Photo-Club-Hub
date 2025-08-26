//
//  PhotographerExpertiseTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 26/02/2025.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests the Core Data PhotographerExpertise class") struct PhotographerExpertiseTest {

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

    @Test("Create a random expertise for a random photographer") func addPhotographerExpertise() {

        let expertiseID = String.random(length: 10).canonicalCase
        let photographerExpertise = PhotographerExpertise.findCreateUpdate(
            context: context,
            photographer: photographer,
            expertise: Expertise.findCreateUpdateNonStandard(context: context, id: expertiseID, names: [], usages: []))
        #expect(photographerExpertise.expertise.id == expertiseID)
        #expect(photographerExpertise.photographer === photographer)
        #expect(photographerExpertise.photographer.givenName == photographer.givenName)
        #expect(photographerExpertise.photographer.infixName == photographer.infixName)
        #expect(photographerExpertise.photographer.familyName == photographer.familyName)
    }

    @Test("Attempt to create duplicate PhotographerExpertise") func duplicatePhotographerExpertise() {

        let expertiseID = String.random(length: 10).canonicalCase // internally expertise.id is capitalized
        let photographerExpertise1 = PhotographerExpertise.findCreateUpdate(
            context: context,
            photographer: photographer,
            expertise: Expertise.findCreateUpdateNonStandard(context: context, id: expertiseID, names: [], usages: []))
        #expect(photographerExpertise1.expertise.id == expertiseID)
        #expect(photographerExpertise1.photographer === photographer)
        #expect(photographerExpertise1.photographer.givenName == photographer.givenName)
        #expect(photographerExpertise1.photographer.infixName == photographer.infixName)
        #expect(photographerExpertise1.photographer.familyName == photographer.familyName)
        PhotographerExpertise.save(context: context)

        let photographerExpertise2 = PhotographerExpertise.findCreateUpdate(
            context: context,
            photographer: photographer, // same photographer
            expertise: Expertise.findCreateUpdateNonStandard(context: context, id: expertiseID,
                                                         names: [], usages: [])) // same expertise
        #expect(photographerExpertise2.expertise.id == expertiseID.canonicalCase)
        #expect(photographerExpertise2.photographer === photographer)
        #expect(photographerExpertise2.photographer.givenName == photographer.givenName)
        #expect(photographerExpertise2.photographer.infixName == photographer.infixName)
        #expect(photographerExpertise2.photographer.familyName == photographer.familyName)
        PhotographerExpertise.save(context: context)

        #expect(photographerExpertise1 == photographerExpertise2)
        #expect(PhotographerExpertise.count(context: context,
                                            expertiseID: expertiseID,
					    photographer: photographer) == 1)
    }

}
