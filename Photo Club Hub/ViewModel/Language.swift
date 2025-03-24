//
//  Language.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 02/03/2024.
//

import CoreData

extension Language {

    @available(*, unavailable)
    convenience init() {
        fatalError("init() is not available. Use .findCreateUpdate instead.")
    }

    fileprivate static var code2Name: [String: String] {
        [
            "DE": "German",
            "EN": "English",
            "ES": "Spanish",
            "FR": "French",
            "NL": "Dutch",
            "PL": "Polish"
        ]
    }

    @MainActor
    static func initConstants() { // called on main thread
        // initConstants shouldn't be necessary, but is there as a temp safety net for concurrenty issues with CoreData
        let viewContext = PersistenceController.shared.container.viewContext // requires foreground context

        for language in code2Name {
            _ = Language.findCreateUpdate(
                context: viewContext, // requires @MainActor
                isoCode: language.key, // converted to all caps within findCreateUpdate
                nameENOptional: language.value // e.g. "English"
            )
        }

        do {
            try viewContext.save() // persist all organizationTypes using main thread ManagedObjectContext
        } catch {
            viewContext.rollback()
            ifDebugFatalError("Couldn't initialize the Language records",
                              file: #fileID, line: #line)
        }
    }

    // MARK: - getters and setters

    fileprivate var isoCode: String {
        get {
            let result = isoCode_?.uppercased() ?? "??"
            if result != isoCode_ {
                isoCode_ = result // update version in CoreData
            }
            return result
        } set {
            isoCode_ = newValue.uppercased()
        }
    }

    var isoCodeAllCaps: String {
        get { isoCode } // e.g. "NL"
        set { isoCode_ = newValue.uppercased() }
    }

    var nameEN: String {
        get { return languageNameEN_?.capitalizingFirstLetter() ?? isoCodeAllCaps } // e.g. Dutch or NL
        set { languageNameEN_ = newValue.capitalizingFirstLetter() }
    }

    // MARK: - find or create

    // Find existing Language object or create a new one.
    // Update existing attributes or fill the new object
    static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground or background thread
                                 isoCode: String,
                                 nameENOptional: String? = nil
                                ) -> Language {

        let isoCodeAllCaps: String = isoCode.uppercased() // "en" -> "EN"
        let predicateFormat: String = "isoCode_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat, argumentArray: [isoCodeAllCaps])
        let fetchRequest: NSFetchRequest<Language> = Language.fetchRequest()
        fetchRequest.predicate = predicate
        var languages: [Language]! = []
        do {
            languages = try context.fetch(fetchRequest)
        } catch {
            ifDebugFatalError("Failed to fetch Language with code \(isoCodeAllCaps)", file: #fileID, line: #line)
            // on non-Debug version, continue with empty `languages` array
        }

        if languages.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("Query returned multiple (\(languages.count)) Languages with code \(isoCodeAllCaps)",
                              file: #fileID, line: #line)
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        if let language = languages.first { // already exists, so update non-identifying attributes
            if language.update(context: context, nameENOptional: nameENOptional) { // nameENOptional can be nil
                print("Updated info for language \"\(language.nameEN)\"")
                if Settings.extraCoreDataSaves {
                    save(context: context, language: language, create: false)
                }
            }
            return language
        } else {
            // cannot use Language() initializer because we must use supplied context
            let entity = NSEntityDescription.entity(forEntityName: "Language", in: context)!
            let language = Language(entity: entity, insertInto: context)
            language.isoCodeAllCaps = isoCode // immediately set it to a non-nil value
            _ = language.update(context: context, nameENOptional: nameENOptional)
            if Settings.extraCoreDataSaves {
                save(context: context, language: language, create: true)
            }
            print("Created new Language for code \(language.isoCodeAllCaps) named \(language.nameEN)")
            return language
        }
    }

    // count number of objects with a given isoCode
    static func count(context: NSManagedObjectContext, isoCode: String) -> Int {
        var languages: [Language]! = []
        let isoCodeAllCaps = isoCode.uppercased()
        let fetchRequest: NSFetchRequest<Language> = Language.fetchRequest()
        let predicateFormat: String = "isoCode_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat, argumentArray: [isoCodeAllCaps])
        fetchRequest.predicate = predicate

        context.performAndWait {
            do {
                languages = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("Failed to fetch Language \(isoCodeAllCaps): \(error)", file: #fileID, line: #line)
                // on non-Debug version, continue with empty `keywords` array
            }
        }

        return languages.count
    }

    // Update non-identifying attributes/properties within an existing instance of class Language if needed.
    // Returns whether an update was needed.
    fileprivate func update(context: NSManagedObjectContext,
                            nameENOptional: String?) -> Bool { // change language.name if needed

        guard let nameEN = nameENOptional else { return false } // nothing to change

        var modified: Bool = false

        if self.nameEN != nameEN {
            self.nameEN = nameEN
            modified = true
        }

        if modified && Settings.extraCoreDataSaves {
            do {
                try context.save() // update modified properties of a Language object
             } catch {
                 ifDebugFatalError("Update failed for Language \(isoCodeAllCaps) aka \(self.nameEN)",
                                  file: #fileID, line: #line)
                // in release mode, if save() fails, just continue
            }
        }

        return modified
    }

    fileprivate static func save(context: NSManagedObjectContext, language: Language, create: Bool) {
        do {
            try context.save()
        } catch {
            context.rollback()
            if create {
                ifDebugFatalError("Could not save created Language \(language.isoCodeAllCaps)")
            } else {
                ifDebugFatalError("Could not save updated property of Language \(language.isoCodeAllCaps)")
            }
        }
    }

}
