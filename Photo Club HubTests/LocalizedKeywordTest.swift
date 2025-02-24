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
//        Model.deleteAllCoreDataObjects() // might be tricky while app is loading in the background TODO
    }

    func randomString(_ length: Int) -> String {
       let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
       let randomString = (0..<length).map { _ in String(letters.randomElement()!) }.reduce("", +)
       return randomString
    }

//    findCreateUpdate(context: NSManagedObjectContext, // can be foreground of background context
//                                 keyword: Keyword,
//                                 language: Language,
//                                 localizedName: String,
//                                 localizedUsage: String?
//                                ) -> LocalizedKeyword

    @Test("Create a randomly named LocalizedKeyword") func addLocalizedKeyword() {
        let keyword = Keyword.findCreateUpdateNonStandard(context: context, id: randomString(5))
        let language = Language.findCreateUpdate(context: context, isoCode: "NL") // "nl" will be different ;-( TODO
        let localizedName = randomString(10)
        let localizedUsage = randomString(20)

        let localizedKeyword =  LocalizedKeyword.findCreateUpdate(context: context,
                                                                  keyword: keyword,
                                                                  language: language,
                                                                  localizedName: localizedName,
                                                                  localizedUsage: localizedUsage)
        localizedKeyword.save(context: context) // probably not needed, but sloppy not to commit this change

        #expect(localizedKeyword.keyword.id == keyword.id)
        #expect(localizedKeyword.language.isoCodeCaps == language.isoCodeCaps)
        #expect(localizedKeyword.language.nameEN == "Dutch")
        #expect(localizedKeyword.name == localizedName)
        #expect(localizedKeyword.usage == localizedUsage)
    }

}
