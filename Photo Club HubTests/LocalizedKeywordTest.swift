//
//  LocalizedKeyword.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 23/02/2025.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests the Core Data LocalizedKeyword class") struct LocalizedKeywordTests {

    fileprivate let context: NSManagedObjectContext

    init () {
        context = PersistenceController.shared.container.viewContext
    }

    @Test("Create a randomly named LocalizedKeyword") func addLocalizedKeyword() {
        let keyword = Keyword.findCreateUpdateNonStandard(context: context, id: String.random(length: 5))
        let language = Language.findCreateUpdate(context: context, isoCode: "NL")
        let localizedName = String.random(length: 10)
        let localizedUsage = String.random(length: 20)

        let localizedKeyword =  LocalizedKeyword.findCreateUpdate(context: context,
                                                                  keyword: keyword,
                                                                  language: language,
                                                                  localizedName: localizedName,
                                                                  localizedUsage: localizedUsage)
        LocalizedKeyword.save(context: context) // probably not needed, but sloppy not to commit this change

        #expect(localizedKeyword.keyword.id == keyword.id)
        #expect(localizedKeyword.language.isoCodeCaps == language.isoCodeCaps)
        #expect(localizedKeyword.language.nameEN == "Dutch")
        #expect(localizedKeyword.name == localizedName)
        #expect(localizedKeyword.usage == localizedUsage)
    }

    @Test("Check that isoCode can handle lower case") func addLocalizedKeywordLowerCase() {
        let keyword = Keyword.findCreateUpdateNonStandard(context: context, id: String.random(length: 25))
        let language = Language.findCreateUpdate(context: context, isoCode: "eN")
        let localizedName = String.random(length: 10)
        let localizedUsage = String.random(length: 20)

        let localizedKeyword =  LocalizedKeyword.findCreateUpdate(context: context,
                                                                  keyword: keyword,
                                                                  language: language,
                                                                  localizedName: localizedName,
                                                                  localizedUsage: localizedUsage)
        LocalizedKeyword.save(context: context) // probably not needed, but sloppy not to commit this change

        #expect(localizedKeyword.language.isoCodeCaps == "EN")
        #expect(localizedKeyword.language.nameEN == "English")
    }

    @Test("Is nil handled properly") func addLocalizedKeywordNilUsage() {
        let keyword = Keyword.findCreateUpdateNonStandard(context: context, id: String.random(length: 25))
        let language = Language.findCreateUpdate(context: context, isoCode: "NL")
        let localizedName = String.random(length: 10)

        let localizedKeyword =  LocalizedKeyword.findCreateUpdate(context: context,
                                                                  keyword: keyword,
                                                                  language: language,
                                                                  localizedName: localizedName,
                                                                  localizedUsage: nil)
        LocalizedKeyword.save(context: context) // probably not needed, but sloppy not to commit this change

        #expect(localizedKeyword.usage == nil)
    }

    @Test("Is nil overwritten properly") func addLocalizedKeywordReplaceNil() {
        let keyword = Keyword.findCreateUpdateNonStandard(context: context, id: String.random(length: 25))
        let language = Language.findCreateUpdate(context: context, isoCode: "NL")
        let localizedName = String.random(length: 10)

        let localizedKeyword1 =  LocalizedKeyword.findCreateUpdate(context: context,
                                                                   keyword: keyword,
                                                                   language: language,
                                                                   localizedName: localizedName,
                                                                   localizedUsage: nil)
        LocalizedKeyword.save(context: context)
        #expect(localizedKeyword1.usage == nil)

        let localizedKeyword2 =  LocalizedKeyword.findCreateUpdate(context: context,
                                                                   keyword: keyword,
                                                                   language: language,
                                                                   localizedName: localizedName,
                                                                   localizedUsage: "overwritten")
        LocalizedKeyword.save(context: context) // probably not needed, but sloppy not to commit this change
        #expect(localizedKeyword2.usage == "overwritten")
        #expect(localizedKeyword1.usage == "overwritten")
        #expect(LocalizedKeyword.count(context: context,
                                       keywordID: keyword.id,
                                       languageIsoCode: language.isoCodeCaps) == 1)
    }

}
