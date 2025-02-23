//
//  LocalizedKeyword.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 23/02/2025.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests the Core Data LocalizedKeyword class") struct LocalizedKeyword {

    fileprivate let context: NSManagedObjectContext

    init () {
        context = PersistenceController.shared.container.viewContext
        Model.deleteAllCoreDataObjects()
    }

    @Test("Add LocalizedKeyword for existing keyword and language") func addLocKeywordExistKeywordExistLanguage() {
    }

    @Test("Add LocalizedKeyword for existing keyword and new language") func addLocKeywordExistKeywordNewLanguage() {
    }

    @Test("Add LocalizedKeyword for new keyword and existing language") func addLocKeywordNewKeywordExistLanguage() {
    }

    @Test("Add LocalizedKeyword for new keyword and language") func addLocKeywordNewKeywordNewLanguage() {
    }

}
