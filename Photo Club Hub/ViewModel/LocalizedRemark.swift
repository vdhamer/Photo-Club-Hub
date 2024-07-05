//
//  LocalizedRemark.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/03/2024.
//

import CoreData // for NSFetchRequest and NSManagedObjectContext

extension LocalizedRemark { // expose computed properties (some related to handling optionals)

    // MARK: - getters (setting is done via init)

    var organization: Organization { // getter
        if let organization = organization_ {
            return organization
        } else {
            fatalError("Error because organization is nil") // something is fundamentally wrong if this happens
        }
    }

    var language: Language { // getter
        if let language = language_ {
            return language
        } else {
            fatalError("Error because language is nil") // something is fundamentally wrong if this happens
        }
    }

    // MARK: - find (if it exits) or create (if it doesn't)

    // Find existing LocalizedRemark object or create a new LocalizedRemark object
    // This function does NOT update non-identifying attributes (use update() for this)
    static func findCreateUpdate(bgContext: NSManagedObjectContext,
                                 organization: Organization, language: Language // identifying attributes only
                                ) -> LocalizedRemark {

        let predicateFormat: String = "organization_ = %@ AND language_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [organization, language]
                                   )
        let fetchRequest: NSFetchRequest<LocalizedRemark> = LocalizedRemark.fetchRequest()
        fetchRequest.predicate = predicate
        // TODO is this the right way to fetch on a background thread? can .fetch fail?
        let localizedRemarks: [LocalizedRemark] = (try? bgContext.fetch(fetchRequest)) ?? [] // nil = absolute failure
        if localizedRemarks.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("Query returned multiple (\(localizedRemarks.count)) remarks for " +
                              "\(organization.fullNameTown) for language code \(language.isoCodeCaps)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        if let localizedRemark = localizedRemarks.first {
            // already exists, so make sure secondary attributes are up to date
            return localizedRemark
        } else {
            let entity = NSEntityDescription.entity(forEntityName: "LocalizedRemark", in: bgContext)!
            let localizedRemark = LocalizedRemark(entity: entity, insertInto: bgContext) // bg needs special .init()
            localizedRemark.organization_ = organization
            localizedRemark.language_ = language
            _ = localizedRemark.update(bgContext: bgContext, localizedString: localizedString)
            do { // robustness in the (illegal?) case of a new localizedRemark without any non-identifying attributes
                if bgContext.hasChanges && Settings.extraCoreDataSaves { // optimisation
                    try bgContext.save() // persist modifications in PhotoClub record
                }
            } catch {
                ifDebugFatalError("Creation of remark failed for \(organization.fullName) in \(language.isoCodeCaps)",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            }
            return localizedRemark
        }
    }

    // Update non-identifying attributes/properties within existing instance of class LocalizedRemark
    // Strange that update is a static function?
    static func update(bgContext: NSManagedObjectContext,
                       localizedRemark: LocalizedRemark,
                       localizedString: String) -> Bool {
        let needsSaving: Bool = localizedString != localizedRemark.localizedString

        if needsSaving && Settings.extraCoreDataSaves {
            do {
                localizedRemark.localizedString = localizedString
                try bgContext.save() // persist just to be sure?
                print("""
                      Stored \(localizedString) \
                      for \(localizedRemark.organization.fullNameTown) \
                      in language \(localizedRemark.language.isoCodeCaps)
                      """)
            } catch {
                ifDebugFatalError("Update failed for localizedRemark \(localizedRemark.organization.fullNameTown) " +
                                  "in language \(localizedRemark.language.isoCodeCaps): \(error)",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, failure to update this data is only logged. And the app doesn't stop.
            }
        }

        return needsSaving
    }

}
