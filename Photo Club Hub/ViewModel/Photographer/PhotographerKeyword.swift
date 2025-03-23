//
//  PhotographerKeyword.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 23/02/2025.
//

import CoreData // for NSManagedObjectContext

extension PhotographerKeyword {

    @available(*, unavailable)
    convenience init() {
        fatalError("init() is not available. Use .findCreateUpdate instead.")
    }

    var keyword: Keyword {
        get {
            if let keyword = keyword_ {
                return keyword
            } else {
                fatalError("Error because keyword is nil") // something is fundamentally wrong if this happens
            }
        }
        set {
            keyword_ = newValue
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

    // Find existing PhotographerKeyword object or create a new one.
    // Update existing attributes or fill the new object
    static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground or background context
                                 photographer: Photographer,
                                 keyword: Keyword
                                ) -> PhotographerKeyword {

        // execute fetchRequest to get keyword object for id=id. Query could return multiple - but shouldn't.
        let fetchRequest: NSFetchRequest<PhotographerKeyword> = PhotographerKeyword.fetchRequest()
        let predicateFormat: String = "keyword_ = %@ AND photographer_ = %@" // avoid localization of query string
        fetchRequest.predicate = NSPredicate(format: predicateFormat, argumentArray: [keyword, photographer])

        var photographerKeywords: [PhotographerKeyword]! = []
        do {
            photographerKeywords = try context.fetch(fetchRequest) // query database
        } catch {
            ifDebugFatalError("""
                              Failed to fetch PhotographerKeyword for \"\(keyword.id)\" \
                              for \(photographer.fullNameFirstLast): \(error)
                              """, file: #fileID, line: #line)
            // on non-Debug version, continue with empty `keywords` array
        }

        // are there multiple copies of the keyword connected to the same photographer? This shouldn't be the case.
        if photographerKeywords.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("""
                              Query returned multiple (\(photographerKeywords.count)) copies \
                              of Keyword \"\(keyword.id)\" for photographer \(photographer.fullNameFirstLast)
                              """,
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        // if a translation already exists, update non-identifying attributes
        if let photographerKeyword = photographerKeywords.first {
            if photographerKeyword.update(context: context) { // actually this class has no non-identifying attributes
                if Settings.extraCoreDataSaves {
                    PhotographerKeyword.save(context: context, errorText:
                                          """
                                          Could not update PhotographerKeyword \
                                          for \"\(photographerKeyword.keyword.id)\" \
                                          for keyword \"\(photographerKeyword.photographer.familyName)\"
                                          """)
                }
            }
            return photographerKeyword
        } else {
            let entity = NSEntityDescription.entity(forEntityName: "PhotographerKeyword", in: context)!
            let photographerKeyword = PhotographerKeyword(entity: entity, insertInto: context)
            photographerKeyword.keyword = keyword
            photographerKeyword.photographer = photographer
            // so far, this class has no other properties to populate
            _ = photographerKeyword.update(context: context)
            if Settings.extraCoreDataSaves {
                LocalizedKeyword.save(context: context, errorText:
                                          """
                                          Could not create PhotographerKeyword for \
                                          \"\(photographerKeyword.keyword.id)\" \
                                          for \(photographerKeyword.photographer.fullNameFirstLast)
                                          """)
            }
            return photographerKeyword
        }

    }

    // Update non-identifying attributes/properties within an existing instance of class LocalizedKeyword if needed.
    // Returns whether an update was needed. But this class (unlike the others) has no relevant properties.
    fileprivate func update(context: NSManagedObjectContext) -> Bool {

        let modified: Bool = false
        // if there is ever anything to modify, this goes here
        return modified
    }

    // MARK: - utilities

    static func save(context: NSManagedObjectContext, errorText: String? = nil) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                ifDebugFatalError(errorText ?? "Error saving PhotographerKeyword")
            }
        }
    }

    // count number of objects with a given id for a given photographer
    static func count(context: NSManagedObjectContext, keywordID: String, photographer: Photographer) -> Int {
        let fetchRequest: NSFetchRequest<PhotographerKeyword> = PhotographerKeyword.fetchRequest()
        let predicateFormat: String = "keyword_.id_ = %@ && photographer_ = %@" // avoid localization
        fetchRequest.predicate = NSPredicate(format: predicateFormat, argumentArray: [keywordID, photographer])

        var photographerKeywords: [PhotographerKeyword]! = []
        context.performAndWait {
            do {
                photographerKeywords = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("""
                                  Failed to fetch PhotographerKeyword \"\(keywordID)\" \
                                  for \(photographer.fullNameFirstLast): \(error)
                                  """,
                                  file: #fileID, line: #line)
                // on non-Debug version, continue with empty `keywords` array
            }
        }
        return photographerKeywords.count
    }

    // count number of objects with a given id
    static func count(context: NSManagedObjectContext, keywordID: String) -> Int {
        var photographerKeywords: [PhotographerKeyword]! = []

        context.performAndWait {
            let fetchRequest: NSFetchRequest<PhotographerKeyword> = PhotographerKeyword.fetchRequest()
            let predicateFormat: String = "keyword_.id_ = %@" // avoid localization
            fetchRequest.predicate = NSPredicate(format: predicateFormat, argumentArray: [keywordID])

            do {
                photographerKeywords = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("""
                                  Failed to fetch PhotographerKeyword \"\(keywordID)\"
                                  """,
                                  file: #fileID, line: #line)
                // on non-Debug version, continue with empty `keywords` array
            }
        }

        return photographerKeywords.count
    }

    // count total number of PhotographerKeyword objects/records
    // there are ways to count without fetching all records, but this func is only used for testing
    static func count(context: NSManagedObjectContext) -> Int {
        let fetchRequest: NSFetchRequest<PhotographerKeyword> = PhotographerKeyword.fetchRequest()
        let predicateAll = NSPredicate(format: "TRUEPREDICATE")
        fetchRequest.predicate = predicateAll

        var photographerKeywords: [PhotographerKeyword]! = []

        context.performAndWait {
            do {
                photographerKeywords = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("""
                                  Failed to fetch PhotographerKeywords: \"\(error)\"
                                  """,
                                  file: #fileID, line: #line)
                // on non-Debug version, continue with empty `keywords` array
            }
        }
        return photographerKeywords.count
    }

}
