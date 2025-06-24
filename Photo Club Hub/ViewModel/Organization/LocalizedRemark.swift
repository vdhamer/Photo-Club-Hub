//
//  LocalizedRemark.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 07/03/2024.
//

import CoreData // for NSFetchRequest and NSManagedObjectContext

extension LocalizedRemark { // expose computed properties (some related to handling optionals)

    @available(*, unavailable)
    convenience init() {
        fatalError("init() is not available. Use .findCreateUpdate instead.")
    }

    // MARK: - getters (setting is done via findCreateUpdate)

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
    static func findCreateUpdate(bgContext: NSManagedObjectContext,
                                 organization: Organization,
                                 language: Language,
                                 localizedString: String
                                ) -> Bool { // true if something got updated

        // get remark if it is already in the database
        let predicateFormat: String = "organization_ = %@ AND language_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [organization, language])
        let fetchRequest: NSFetchRequest<LocalizedRemark> = LocalizedRemark.fetchRequest()
        fetchRequest.predicate = predicate
        let localizedRemarks: [LocalizedRemark] = (try? bgContext.fetch(fetchRequest)) ?? [] // nil = absolute failure
        if localizedRemarks.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("Query returned multiple (\(localizedRemarks.count)) remarks for " +
                              "\(organization.fullNameTown) for language code \(language.isoCodeAllCaps)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        if let localizedRemark = localizedRemarks.first, localizedRemark.localizedString==localizedString {
            let changed: Bool = localizedRemark.update(bgContext: bgContext, localizedString: localizedString)
            return changed // the record is already in CoreData, but property may have changed
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
                ifDebugFatalError("""
                                  Creation of remark failed for \(organization.fullName) \
                                  in language \(language.isoCodeAllCaps)
                                  """,
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            }
            return true // something got updated
        }
    }

    // Update non-identifying attributes/properties within existing instance of class LocalizedRemark
    fileprivate func update(bgContext: NSManagedObjectContext,
                            localizedString: String) -> Bool { // true if something got updated
        guard self.localizedString != localizedString else { return false } // nothing to change
        self.localizedString = localizedString // update string
        return true // indicates that there was an update
    }

    // count total number of objects in CoreData database
    static func count(context: NSManagedObjectContext) -> Int {
        var localizedRemarks: [LocalizedRemark]! = []

        context.performAndWait {
            let fetchRequest: NSFetchRequest<LocalizedRemark> = LocalizedRemark.fetchRequest()
            let predicateAll = NSPredicate(format: "TRUEPREDICATE")
            fetchRequest.predicate = predicateAll

            context.perform {
                do {
                    localizedRemarks = try context.fetch(fetchRequest)
                } catch {
                    ifDebugFatalError("Failed to fetch list of all LocalizedLanguages: \(error)",
                                      file: #fileID, line: #line)
                    // on non-Debug version, continue with empty `localizedRemarks` array
                }
            }
        }
        return localizedRemarks.count
    }

}
