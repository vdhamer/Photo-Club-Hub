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
            "DE": "Deutsch",
            "EN": "English",
            "ES": "Español",
            "FR": "Français",
            "NL": "Nederlands",
            "PL": "Polski"
        ]
    }

    // MARK: - getters and setters

    var isoCodeCaps: String {
        get { return isoCode_?.uppercased() ?? "??"} // e.g. NL
        set { isoCode_ = newValue.uppercased() }
    }

    var name: String {
        get { return (languageName_ ?? isoCodeCaps).capitalized } // e.g. Nederlands or Nl
        set { languageName_ = newValue.capitalized }
    }

    // MARK: - find or create

    // Find Language object (or create a new object - used at start of app)
    // Update existing attributes or fill the new object
    static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground of background context
                                 isoCode: String,
                                 name inputName: String? = nil
                                ) -> Language {

        let name = inputName ?? code2Name[isoCode] // fill in name if no name provided and dictionary contains name
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
            if let name {
                if language.update(context: context, name: name) {
                    print("Updated info for language \"\(language.name)\"")
                    save(context: context, language: language, create: false)
                }
            }
            return language
        } else {
            // cannot use Language() initializer because we must use supplied context
            let entity = NSEntityDescription.entity(forEntityName: "Language", in: context)!
            let language = Language(entity: entity, insertInto: context)
            language.isoCodeCaps = isoCode
            _ = language.update(context: context, name: name)
            save(context: context, language: language, create: true)
            print("Created new Language for code \(language.isoCodeCaps) named \(language.name)")
            return language
        }
    }

    // Update non-identifying attributes/properties within an existing instance of class Language
    fileprivate func update(context: NSManagedObjectContext,
                            name: String?) -> Bool { // change language.name if needed

        var modified: Bool = false

        if let name, self.name != name {
            self.name = name
            modified = true
        }

        if modified && Settings.extraCoreDataSaves {
            do {
                try context.save() // update modified properties of a Language object
             } catch {
                 ifDebugFatalError("Update failed for Language \(isoCodeCaps) aka \(self.name)",
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
            if create {
                ifDebugFatalError("Could not save created Language \(language.isoCodeCaps)")
            } else {
                ifDebugFatalError("Could not save updated property of Language \(language.isoCodeCaps)")
            }
        }
    }

}
