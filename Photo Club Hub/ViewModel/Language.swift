//
//  Language.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 02/03/2024.
//

import CoreData

extension Language {

    static func initConstants() { // called on main thread
        guard Thread.isMainThread else { fatalError("OrganizationType.initConstants() must be on main thread") }
        guard OrganizationType.enum2objectID.isEmpty else {
            fatalError("Repeated call to OrganizationalType.initConstants")
        }

        let viewContext = PersistenceController.shared.container.viewContext // foreground context

        for type in OrganizationTypeEnum.allCases { // type is simple enum
            let organizationType = OrganizationType.findCreateUpdate( // organizationType is CoreData NSManagedObject
                context: viewContext,
                name: type.unlocalizedSingular
            )
            OrganizationType.enum2objectID[type] = organizationType.objectID // access NSManagedObjects from bg threads
        }

        do {
            try viewContext.save() // persist all organizationTypes using main thread ManagedObjectContext
        } catch {
            ifDebugFatalError("Couldn't initialize both organizationType records",
                              file: #fileID, line: #line)
        }

    }

    // MARK: - getters and setters

    var isoCode: String {
        get { return isoCode_ ?? "??"}
        set { isoCode_ = newValue }
    }

    var name: String {
        get { return name_ ?? "NoNameForLangauge\(self.isoCode)" }
        set { name_ = newValue }
    }

    // MARK: - find or create

    // Find Language object (or create a new object - used at start of app)
    // Update existing attributes or fill the new object
    static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground of background context
                                 isoCode: String,
                                 name inputName: String?
                                ) -> Language {

        let predicateFormat: String = "name_ = %@" // avoid localization
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
            if let name = inputName {
                if update(context: context, language: language, name: name) {
                    print("Updated info for organization type \"\(language.name)\"")
                    save(context: context, language: language, create: false)
                }
            }
            return language
        } else {
            // cannot use Language() initializer because we must use supplied context
            let entity = NSEntityDescription.entity(forEntityName: "Language", in: context)!
            let language = Language(entity: entity, insertInto: context)
            if let inputName {
                language.name = inputName
            }
            _ = update(context: context, language: language, name: inputName)
            save(context: context, language: language, create: true)
            print("Created new Language for code \(language.isoCode) named \(language.name)")
            return language
        }
    }

    // Update non-identifying attributes/properties within an existing instance of class Language
    static func update(context: NSManagedObjectContext,
                       language: Language,
                       name: String?) -> Bool { // change language.name if needed

        var modified: Bool = false

        if let name, language.name != name {
            language.name = name
            modified = true
        }

        if modified {
            do {
                try context.save() // update modified properties of a Language object
             } catch {
                 ifDebugFatalError("Update failed for Language \(language.isoCode) aka \(language.name)",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, if save() fails, just continue
                modified = true
            }
        }

        return modified
    }

    private static func save(context: NSManagedObjectContext, language: Language, create: Bool) {
        do {
            try context.save()
        } catch {
            if create {
                ifDebugFatalError("Could not save created Language \(language.isoCode)")
            } else {
                ifDebugFatalError("Could not save updated property of Language \(language.isoCode)")
            }
        }
    }

}
