//
//  Language.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 02/03/2024.
//

import CoreData

extension Language {

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
                isoCode: language.key, // e.g. "EN"
                nameENOptional: language.value // e.g. "English"
            )
        }

        do {
            try viewContext.save() // persist all organizationTypes using main thread ManagedObjectContext
        } catch {
            viewContext.rollback()
            ifDebugFatalError("Couldn't initialize the three organizationType records",
                              file: #fileID, line: #line)
        }
    }

    // MARK: - getters and setters

    var isoCodeCaps: String {
        get { return isoCode_?.uppercased() ?? "??"} // e.g. "NL"
        set { isoCode_ = newValue.uppercased() }
    }

    var nameEN: String {
        get { return (languageNameEN_ ?? isoCodeCaps).capitalized } // e.g. Nederlands or Nl
        set { languageNameEN_ = newValue.capitalized }
    }

    // MARK: - find or create

    // Find existing Language object or create a new one.
    // Update existing attributes or fill the new object
    static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground of background context
                                 isoCode: String,
                                 nameENOptional: String? = nil
                                ) -> Language {

        let nameEN: String = nameENOptional ?? code2Name[isoCode] ?? "Name?" // fill in name if no name provided
        let predicateFormat: String = "isoCode_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat, argumentArray: [isoCode])
        let fetchRequest: NSFetchRequest<Language> = Language.fetchRequest()
        fetchRequest.predicate = predicate
        let languages: [Language] = (try? context.fetch(fetchRequest)) ?? [] // nil = absolute failure

        if languages.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("Query returned multiple (\(languages.count)) Languages with code \(isoCode)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        if let language = languages.first { // already exists, so update non-identifying attributes
            if language.update(context: context, nameEN: nameEN) {
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
            language.isoCodeCaps = isoCode
            _ = language.update(context: context, nameEN: nameEN)
            if Settings.extraCoreDataSaves {
                save(context: context, language: language, create: true)
            }
           print("Created new Language for code \(language.isoCodeCaps) named \(language.nameEN)")
            return language
        }
    }

    // Update non-identifying attributes/properties within an existing instance of class Language
    fileprivate func update(context: NSManagedObjectContext,
                            nameEN: String) -> Bool { // change language.name if needed

        var modified: Bool = false

        if self.nameEN != nameEN {
            self.nameEN = nameEN
            modified = true
        }

        if modified && Settings.extraCoreDataSaves {
            do {
                try context.save() // update modified properties of a Language object
             } catch {
                 ifDebugFatalError("Update failed for Language \(isoCodeCaps) aka \(self.nameEN)",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
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
                ifDebugFatalError("Could not save created Language \(language.isoCodeCaps)")
            } else {
                ifDebugFatalError("Could not save updated property of Language \(language.isoCodeCaps)")
            }
        }
    }

}
