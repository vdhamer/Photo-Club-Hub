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

    fileprivate let context: NSManagedObjectContext

    init () {
        context = PersistenceController.shared.container.viewContext
    }

    @Test("Create a randomly named LocalizedExpertise") func addLocalizedExpertise() {
        let expertise = Expertise.findCreateUpdateNonStandard(context: context, id: String.random(length: 5),
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
        let expertise = Expertise.findCreateUpdateNonStandard(context: context, id: String.random(length: 25),
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
        let expertise = Expertise.findCreateUpdateNonStandard(context: context, id: String.random(length: 25),
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
        let expertise = Expertise.findCreateUpdateNonStandard(context: context, id: String.random(length: 25),
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
