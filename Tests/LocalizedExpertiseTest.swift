//
//  LocalizedExertiseTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 23/02/2025.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests the Core Data LocalizedExpertise class") struct LocalizedExpertiseTest {

    private let testPersistenceController: PersistenceController
    private let context: NSManagedObjectContext

    init () {
        // Use a private in-memory store rather than PersistenceController.shared. Sharing the singleton
        // coordinator across parallel suites deadlocks (main-queue performAndWait fetches contending with
        // background-context saves) and lets suites pollute each other's records. See issue #756.
        testPersistenceController = PersistenceController(inMemory: true)
        context = testPersistenceController.container.viewContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        // Seed the Language rows so nameEN resolves to "Dutch"/"English" (assertions below); without a
        // seeded name, Language.nameEN falls back to the ISO code. initConstants must run on the main-queue
        // viewContext (it does a bare save()). See #749.
        Language.initConstants(context: context)
    }

    @Test("Create a randomly named LocalizedExpertise") func addLocalizedExpertise() {
        let expertise = Expertise.findCreateUpdateTemporary(context: context, id: String.random(length: 5),
                                                              names: [], usages: [])
        let language = Language.findCreateUpdate(context: context, isoCode: "NL")
        let localizedName = String.random(length: 10)
        let localizedUsage = String.random(length: 20)

        let localizedExpertise =  LocalizedExpertise.findCreateUpdate(context: context,
                                                                      expertise: expertise,
                                                                      language: language,
                                                                      localizedName: localizedName,
                                                                      localizedUsage: localizedUsage)
        LocalizedExpertise.save(context: context) // probably not needed, but sloppy not to commit this change

        #expect(localizedExpertise.expertise.id == expertise.id.canonicalCase)
        #expect(localizedExpertise.language.isoCode == language.isoCode)
        #expect(localizedExpertise.language.nameEN == "Dutch")
        #expect(localizedExpertise.name == localizedName)
        #expect(localizedExpertise.usage == localizedUsage)
    }

    @Test("Check that isoCode can handle lower case") func addLocalizedExpertiseLowerCase() {
        let expertise = Expertise.findCreateUpdateTemporary(context: context, id: String.random(length: 25),
                                                              names: [], usages: [])
        let language = Language.findCreateUpdate(context: context, isoCode: "eN")
        let localizedName = String.random(length: 10)
        let localizedUsage = String.random(length: 20)

        let localizedExpertise =  LocalizedExpertise.findCreateUpdate(context: context,
                                                                      expertise: expertise,
                                                                      language: language,
                                                                      localizedName: localizedName,
                                                                      localizedUsage: localizedUsage)
        LocalizedExpertise.save(context: context) // probably not needed, but sloppy not to commit this change

        #expect(localizedExpertise.language.isoCode == "EN")
        #expect(localizedExpertise.language.nameEN == "English")
    }

    @Test("Is nil handled properly") func addLocalizedExpertiseNilUsage() {
        let expertise = Expertise.findCreateUpdateTemporary(context: context, id: String.random(length: 25),
                                                              names: [], usages: [])
        let language = Language.findCreateUpdate(context: context, isoCode: "NL")
        let localizedName = String.random(length: 10)

        let localizedExpertise =  LocalizedExpertise.findCreateUpdate(context: context,
                                                                      expertise: expertise,
                                                                      language: language,
                                                                      localizedName: localizedName,
                                                                      localizedUsage: nil)
        LocalizedExpertise.save(context: context) // probably not needed, but sloppy not to commit this change

        #expect(localizedExpertise.usage == nil)
    }

    @Test("Is nil overwritten properly") func addLocalizedExpertiseReplaceNil() {
        let expertise = Expertise.findCreateUpdateTemporary(context: context, id: String.random(length: 25),
                                                              names: [], usages: [])
        let language = Language.findCreateUpdate(context: context, isoCode: "NL")
        let localizedName = String.random(length: 10)

        let localizedExpertise1 =  LocalizedExpertise.findCreateUpdate(context: context,
                                                                       expertise: expertise,
                                                                       language: language,
                                                                       localizedName: localizedName,
                                                                       localizedUsage: nil)
        LocalizedExpertise.save(context: context)
        #expect(localizedExpertise1.usage == nil)

        let localizedExpertise2 =  LocalizedExpertise.findCreateUpdate(context: context,
                                                                       expertise: expertise,
                                                                       language: language,
                                                                       localizedName: localizedName,
                                                                       localizedUsage: "overwritten")
        LocalizedExpertise.save(context: context) // probably not needed, but sloppy not to commit this change
        #expect(localizedExpertise2.usage == "overwritten")
        #expect(localizedExpertise1.usage == "overwritten")
        #expect(LocalizedExpertise.count(context: context,
                                         expertiseID: expertise.id,
                                         languageIsoCode: language.isoCode) == 1)
    }

}
