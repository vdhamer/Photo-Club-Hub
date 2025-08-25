//
//  LocalizedExpertise.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 23/02/2025.
//

import CoreData // for NSManagedObjectContext

extension LocalizedExpertise: Comparable {
    public static func < (lhs: LocalizedExpertise, rhs: LocalizedExpertise) -> Bool {
        return lhs.name < rhs.name
    }
}

extension LocalizedExpertise {

    @available(*, unavailable)
    convenience init() {
        fatalError("init() is not available. Use .findCreateUpdate instead.")
    }

    // MARK: - getters (setting is done via findCreateUpdate)

    public var name: String {
        get {
            if let name = name_ {
                return name
            } else {
                fatalError("Error because LocalizedExpertise.name_ is nil") // something is really wrong if this happens
            }
        }
        set {
            name_ = newValue
        }
    }

    var expertise: Expertise { // getter
        if let expertise = expertise_ {
            return expertise
        } else {
            fatalError("Error because expertise is nil") // something is fundamentally wrong if this happens
        }
    }

    var language: Language { // getter
        if let language = language_ {
            return language
        } else {
            fatalError("Error because language is nil") // something is fundamentally wrong if this happens
        }
    }

    // MARK: - find or create

    // Find existing Expertise object or create a new one.
    // Update existing attributes or fill the new object
    static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground or background context
                                 expertise: Expertise,
                                 language: Language,
                                 localizedName: String?, // nil used if no update to LocalizedExpertise.name is desired
                                 localizedUsage: String? // nil used if no value of LocalizedExpertise.usage available
                                ) -> LocalizedExpertise {

        // execute fetchRequest to get Expertise for id=id. Query could return multiple expertises - but shouldn't.
        let fetchRequest: NSFetchRequest<LocalizedExpertise> = LocalizedExpertise.fetchRequest()
        let predicateFormat: String = "expertise_ = %@ AND language_ = %@" // avoid localization of query string
        fetchRequest.predicate = NSPredicate(format: predicateFormat, argumentArray: [expertise, language])

        var localizedExpertises: [LocalizedExpertise]! = []
        do {
            localizedExpertises = try context.fetch(fetchRequest)
        } catch {
            ifDebugFatalError("Failed to fetch LocalizedExpertise for \(expertise.id) " +
                              "in language \(language.isoCode): \(error)",
                              file: #fileID, line: #line) // on release version, continue with empty `expertises` array
        }

        // are there multiple translations of the expertise into the same language? This shouldn't be the case.
        if localizedExpertises.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("Query returned multiple (\(localizedExpertises.count)) translations " +
                              "of Expertise \(expertise.id) into \(language.isoCode)",
                              file: #fileID, line: #line)
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        // if a translation already exists, update non-identifying attributes
        if let localizedExpertise = localizedExpertises.first {
            if localizedExpertise.update(context: context,
                                         localizedName: localizedName, localizedUsage: localizedUsage) {
                print("""
                      Updated translation of expertise \"\(expertise.id)\" into \
                      \(language.isoCode) as \(localizedName ?? "nil")
                      """)
                LocalizedExpertise.save(context: context, errorText:
                                        "Could not update LocalizedExpertise " +
                                        "for \"\(localizedExpertise.expertise.id)\" " +
                                        "for language \(localizedExpertise.language.isoCode)",
                                        if: Settings.extraCoreDataSaves)
            }
            return localizedExpertise
        } else {
            let entity = NSEntityDescription.entity(forEntityName: "LocalizedExpertise", in: context)!
            let localizedExpertise = LocalizedExpertise(entity: entity, insertInto: context)
            if localizedName != nil {
                localizedExpertise.name = localizedName!
            }
            localizedExpertise.expertise_ = expertise
            localizedExpertise.language_ = language
            _ = localizedExpertise.update(context: context,
                                          localizedName: localizedName, localizedUsage: localizedUsage)
            LocalizedExpertise.save(context: context, errorText:
                                    """
                                    Could not create LocalizedExpertise for \"\(localizedExpertise.expertise.id)\" \
                                    for language \(localizedExpertise.language.isoCode)
                                    """,
                                    if: Settings.extraCoreDataSaves)
            return localizedExpertise
        }

     }

    // Update non-identifying attributes/properties within an existing instance of class LocalizedExpertise if needed.
    // Returns whether an update was needed.
    fileprivate func update(context: NSManagedObjectContext,
                            localizedName: String?,
                            localizedUsage: String?) -> Bool {

        var modified: Bool = false

        if let localizedName, self.name != localizedName {
            self.name = localizedName
            modified = true
        }

        if let localizedUsage, self.usage != localizedUsage {
            self.usage = localizedUsage
            modified = true
        }

        if modified && Settings.extraCoreDataSaves {
            do {
                try context.save() // update modified properties of a Expertise object
             } catch {
                 ifDebugFatalError("""
                                   Update failed for LocalizedExpertise \
                                   (\(self.expertise.id) | \(self.language.isoCode))
                                   """,
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, if save() fails, just continue
            }
        }

        return modified
    }

    // MARK: - utilities

    static func save(context: NSManagedObjectContext, errorText: String? = nil, if condition: Bool = true) {
        if context.hasChanges, condition {
            do {
                try context.save()
            } catch {
                context.rollback()
                ifDebugFatalError(errorText ?? "Error saving LocalizedExpertise")
            }
        }
    }

    /// Returns the total number of `LocalizedExpertise` objects in the Core Data database.
    ///
    /// - Parameter context: The `NSManagedObjectContext` used to perform the fetch.
    /// - Returns: The total count of `LocalizedExpertise` records, or 0 if an error occurs.
    static func count(context: NSManagedObjectContext) -> Int {

        let localizedExpertiseCount: Int = context.performAndWait {
            let fetchRequest: NSFetchRequest<LocalizedExpertise> = LocalizedExpertise.fetchRequest()
            let predicateAll = NSPredicate(format: "TRUEPREDICATE")
            fetchRequest.predicate = predicateAll

            do {
                return try context.fetch(fetchRequest).count
            } catch {
                ifDebugFatalError("Failed to fetch list of all LocalizedExpertises: \(error)",
                                  file: #fileID, line: #line)
                // on non-Debug version, continue with empty `expertises` array
                return 0
            }
        }

        return localizedExpertiseCount
    }

    /// Returns the number of `LocalizedExpertise` objects in the Core Data database
    /// matching the specified expertise and language ISO code.
    ///
    /// - Parameters:
    ///   - context: The `NSManagedObjectContext` used to perform the fetch.
    ///   - expertiseID: The unique identifier for the `Expertise` entity to match.
    ///   - languageIsoCode: The ISO code for the Language to match.
    /// - Returns: The count of `LocalizedExpertise` records matching both criteria, or 0 if an error occurs.
    static func count(context: NSManagedObjectContext, expertiseID: String, languageIsoCode: String) -> Int {

        let localizedExpertiseCount: Int = context.performAndWait {
            let expertiseIDCanonical = expertiseID.canonicalCase
            let fetchRequest: NSFetchRequest<LocalizedExpertise> = LocalizedExpertise.fetchRequest()
            let predicateFormat: String = "expertise_.id_ = %@ && language_.isoCode_ = %@" // avoid localization
            fetchRequest.predicate = NSPredicate(format: predicateFormat,
                                                 argumentArray: [expertiseIDCanonical, languageIsoCode])

            do {
                return try context.fetch(fetchRequest).count
            } catch {
                ifDebugFatalError("""
                                  Failed to fetch LocalizedExpertise \(expertiseIDCanonical) \
                                  for \(languageIsoCode): \(error)
                                  """,
                                  file: #fileID, line: #line)
                // on non-Debug version, continue with empty `expertises` array
                return 0
            }
        }

        return localizedExpertiseCount
    }

}
