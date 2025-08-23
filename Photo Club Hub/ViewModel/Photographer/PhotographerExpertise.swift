//
//  PhotographerExpertise.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 23/02/2025.
//

import CoreData // for NSManagedObjectContext

extension PhotographerExpertise {

    @available(*, unavailable)
    convenience init() {
        fatalError("init() is not available. Use .findCreateUpdate instead.")
    }

    var expertise: Expertise {
        get {
            if let expertise = expertise_ {
                return expertise
            } else {
                fatalError("Error because expertise is nil") // something is fundamentally wrong if this happens
            }
        }
        set {
            expertise_ = newValue
        }
    }

    var photographer: Photographer {
        get {
            if let photographer = photographer_ {
                return photographer
            } else {
                fatalError("Error because photographer is nil") // something is fundamentally wrong if this happens
            }
        }
        set {
            photographer_ = newValue
        }
    }

    // MARK: - find or create

    // Find existing PhotographerExpertise object or create a new one.
    // Update existing attributes or fill the new object
    static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground or background context
                                 photographer: Photographer,
                                 expertise: Expertise
                                ) -> PhotographerExpertise {

        // execute fetchRequest to get expertise object for id=id. Query could return multiple - but shouldn't.
        let fetchRequest: NSFetchRequest<PhotographerExpertise> = PhotographerExpertise.fetchRequest()
        let predicateFormat: String = "expertise_ = %@ AND photographer_ = %@" // avoid localization of query string
        fetchRequest.predicate = NSPredicate(format: predicateFormat, argumentArray: [expertise, photographer])

        var photographerExpertise: [PhotographerExpertise]! = []
        do {
            photographerExpertise = try context.fetch(fetchRequest) // query database
        } catch {
            ifDebugFatalError("""
                              Failed to fetch PhotographerExpertise for \"\(expertise.id)\" \
                              for \(photographer.fullNameFirstLast): \(error)
                              """, file: #fileID, line: #line)
            // on non-Debug version, continue with empty `expertise` array
        }

        // are there multiple copies of the expertise connected to the same photographer? This shouldn't be the case.
        if photographerExpertise.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("""
                              Query returned multiple (\(photographerExpertise.count)) copies \
                              of Expertise \"\(expertise.id)\" for photographer \(photographer.fullNameFirstLast)
                              """,
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        // if a translation already exists, update non-identifying attributes
        if let photographerExpertise = photographerExpertise.first {
            if photographerExpertise.update(context: context) { // actually this class has no non-identifying attributes
                if Settings.extraCoreDataSaves {
                    PhotographerExpertise.save(context: context, errorText:
                                          """
                                          Could not update PhotographerExpertise \
                                          for \"\(photographerExpertise.expertise.id)\" \
                                          for expertise \"\(photographerExpertise.photographer.familyName)\"
                                          """)
                }
            }
            return photographerExpertise
        } else {
            let entity = NSEntityDescription.entity(forEntityName: "PhotographerExpertise", in: context)!
            let photographerExpertise = PhotographerExpertise(entity: entity, insertInto: context)
            photographerExpertise.expertise = expertise
            photographerExpertise.photographer = photographer
            // so far, this class has no other properties to populate
            _ = photographerExpertise.update(context: context)
            if Settings.extraCoreDataSaves {
                LocalizedExpertise.save(context: context, errorText:
                                        """
                                        Could not create PhotographerExpertise for \
                                        \"\(photographerExpertise.expertise.id)\" \
                                        for \(photographerExpertise.photographer.fullNameFirstLast)
                                        """)
            }
            return photographerExpertise
        }

    }

    // Update non-identifying attributes/properties within an existing instance of class LocalizedExpertise if needed.
    // Returns whether an update was needed. But this class (unlike the others) has no relevant properties.
    fileprivate func update(context: NSManagedObjectContext) -> Bool {

        let modified: Bool = false
        // if there is ever anything to modify, this goes here
        return modified
    }

    // MARK: - save

    static func save(context: NSManagedObjectContext, errorText: String? = nil) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                ifDebugFatalError(errorText ?? "Error saving PhotographerExpertise")
            }
        }
    }

    // MARK: - count

    // count number of objects with a given id for a given photographer
    static func count(context: NSManagedObjectContext, expertiseID: String, photographer: Photographer) -> Int {

        // Photographer is not sendable, but Strings are.
        // Could have used Photographer.objectID as well, but then there is no photographer name for error messages.
        let person = (photographer.givenName, photographer.infixName, photographer.familyName)

        let photographerExpertiseCount: Int = context.performAndWait {
            let fetchRequest: NSFetchRequest<PhotographerExpertise> = PhotographerExpertise.fetchRequest()
            let predicateFormat: String = """
                                          expertise_.id_ = %@ \
                                          && photographer_.givenName_ = %@ \
                                          && photographer_.infixName_ = %@ \
                                          && photographer_.familyName_ = %@
                                          """ // avoid localization
            fetchRequest.predicate = NSPredicate(format: predicateFormat,
                                                 argumentArray: [expertiseID.canonicalCase,
                                                                 person.0, person.1, person.2])

            var photographerExpertises: [PhotographerExpertise]! = []

            do {
                photographerExpertises = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("""
                                  Failed to fetch PhotographerExpertise \"\(expertiseID)\" \
                                  for \(person.0) \(person.1) \(person.2): \(error)
                                  """,
                                  file: #fileID, line: #line)
                // on non-Debug version, continue with empty `expertise` array
            }
            return photographerExpertises.count
        }

        return photographerExpertiseCount
    }

    // count number of objects with a given id
    static func count(context: NSManagedObjectContext, expertiseID: String) -> Int {

        let photographerExpertiseCount: Int = context.performAndWait {
            let fetchRequest: NSFetchRequest<PhotographerExpertise> = PhotographerExpertise.fetchRequest()
            let predicateFormat: String = "expertise_.id_ = %@" // avoid localization
            fetchRequest.predicate = NSPredicate(format: predicateFormat,
                                                 argumentArray: [expertiseID.canonicalCase])

            var photographerExpertises: [PhotographerExpertise]! = []

            do {
                photographerExpertises = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("""
                                  Failed to fetch PhotographerExpertise \"\(expertiseID)\"
                                  """,
                                  file: #fileID, line: #line)
                // on non-Debug version, continue with empty `Expertise` array
            }
            return photographerExpertises.count
        }

        return photographerExpertiseCount
    }

    // count total number of PhotographerExpertise objects/records
    // there are ways to count without fetching all records, but this func is only used for testing
    static func count(context: NSManagedObjectContext) -> Int {

        let photographerExpertiseCount: Int = context.performAndWait {
            let fetchRequest: NSFetchRequest<PhotographerExpertise> = PhotographerExpertise.fetchRequest()
            let predicateAll = NSPredicate(format: "TRUEPREDICATE")
            fetchRequest.predicate = predicateAll

            var photographerExpertises: [PhotographerExpertise]! = []

            do {
                photographerExpertises = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("""
                                  Failed to fetch PhotographerExpertises: \"\(error)\"
                                  """,
                                  file: #fileID, line: #line)
                // on non-Debug version, continue with empty `expertise` array
            }
            return photographerExpertises.count
        }

        return photographerExpertiseCount
    }

}
