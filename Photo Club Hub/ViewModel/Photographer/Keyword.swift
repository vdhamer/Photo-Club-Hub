//
//  Keyword.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 19/02/2025.
//

import CoreData // for NSManagedObjectContext

extension Keyword {

    @available(*, unavailable)
    convenience init() {
        fatalError("init() is not available. Use .findCreateUpdate instead.")
    }

    // `id` is persisted in CoreData as `id_` but has to be public because it is also used for the Identifiable protocol
    public var id: String {
        get {
            if id_ != nil { // shouldn't be nil in the first place
                return id_!
            } else {
                ifDebugFatalError("CoreData id_ for Keyword is nil", file: #fileID, line: #line)
                return "No id for Keyword"
            }
        }
        set {
            id_ = newValue.capitalized // ensure CoreData always contains string with first letter capitalized
        }
    }

    // MARK: - find or create

    // Find existing Keyword object or create a new one.
    // Update existing attributes or fill the new object
    fileprivate static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground or background context
                                             id: String,
                                             isStandard: Bool? // nil means don't change existing value
                                            ) -> Keyword {

        // execute fetchRequest to get keyword object for id=id. Query could return multiple - but shouldn't.
        let fetchRequest: NSFetchRequest<Keyword> = Keyword.fetchRequest()
        let predicateFormat: String = "id_ = %@" // avoid localization
        fetchRequest.predicate = NSPredicate(format: predicateFormat, argumentArray: [id])

        var keywords: [Keyword]! = []
        do {
            keywords = try context.fetch(fetchRequest)
        } catch {
            ifDebugFatalError("Failed to fetch Keyword \(id): \(error)", file: #fileID, line: #line)
            // on non-Debug version, continue with empty `keywords` array
        }

        // are there multiple copies of the keyword? This shouldn't be the case.
        if keywords.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("Query returned multiple (\(keywords.count)) Keywords with code \(id)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        if let keyword = keywords.first { // already exists, so update non-identifying attributes
            if keyword.update(context: context, isStandard: isStandard) {
                if isStandard == nil {
                    ifDebugFatalError("Updated keyword \(keyword.id).isStandard to nil (which is suspicious)")
                } else {
                    print("Updated keyword \(keyword.id).isStandard to \(isStandard! ? "" : "non-")standard")
                }
                if Settings.extraCoreDataSaves {
                    Keyword.save(context: context, errorText: "Could not update Keyword \"\(keyword.id)\"")
                }
            }
            return keyword
        } else {
            // cannot use Keyword() initializer because we must use supplied context
            let entity = NSEntityDescription.entity(forEntityName: "Keyword", in: context)!
            let keyword = Keyword(entity: entity, insertInto: context)
            keyword.id = id // immediately set it to a non-nil value
            _ = keyword.update(context: context, isStandard: isStandard) // ignore whether update made changes
            if Settings.extraCoreDataSaves {
                Keyword.save(context: context, errorText: "Could not save Keyword \"\(keyword.id)\"")
            }
            print("Created new Keyword called \"\(keyword.id)\"")
            return keyword
        }

    }

    // Find existing standard Keyword object or create a new one.
    // Update existing attributes or fill the new object
    static func findCreateUpdateStandard(context: NSManagedObjectContext, // can be foreground or background context
                                         id: String
                                        ) -> Keyword {
        findCreateUpdate(context: context, id: id, isStandard: true)
    }

    // Find existing non-standard Keyword object or create a new one.
    // Update existing attributes or fill the new object
    static func findCreateUpdateNonStandard(context: NSManagedObjectContext, // can be foreground or background context
                                            id: String
                                           ) -> Keyword {
        findCreateUpdate(context: context, id: id, isStandard: false)
    }

    // Find existing Keyword object or create a new one without changing the Standard flag.
    // Don't update existing Standard attribute
    static func findCreateUpdateUndefStandard(context: NSManagedObjectContext, // can be foreground or background cntxt
                                              id: String
                                             ) -> Keyword {
        findCreateUpdate(context: context, id: id, isStandard: nil)
    }

    // Update non-identifying attributes/properties within an existing instance of class Keyword if needed.
    // Returns whether an update was needed.
    fileprivate func update(context: NSManagedObjectContext,
                            isStandard: Bool? // nil means don't change
                           ) -> Bool {

        var updated: Bool = false

        if isStandard != nil, self.isStandard != isStandard {
            self.isStandard = isStandard!
            if Settings.extraCoreDataSaves {
                do {
                    try context.save() // update modified properties of a Keyword object
                 } catch {
                     ifDebugFatalError("Update failed for Keyword \"\(id)\"",
                                      file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                    // in release mode, if save() fails, just continue
                }
            }
            updated = true // value changed, but maybe not saved yet
        }

        return updated
    }

    // MARK: - utilities

    func delete(context: NSManagedObjectContext) { // for testing?
        context.delete(self)
        do {
            try context.save()
        } catch {
            context.rollback()
            ifDebugFatalError("Could not save the deletion of Keyword \"\(self.id)\"")
        }
    }

    static func save(context: NSManagedObjectContext, errorText: String? = nil) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                ifDebugFatalError(errorText ?? "Error saving Keyword")
            }
        }
    }

    // count number of Keywords with a given id
    static func count(context: NSManagedObjectContext, keywordID: String) -> Int {
        var keywords: [Keyword]! = []

        let fetchRequest: NSFetchRequest<Keyword> = Keyword.fetchRequest()
        let predicateFormat: String = "id_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat, argumentArray: [keywordID])
        fetchRequest.predicate = predicate
        do {
            keywords = try context.fetch(fetchRequest)
        } catch {
            ifDebugFatalError("Failed to fetch Keyword \(keywordID): \(error)", file: #fileID, line: #line)
        }
        return keywords.count
    }

    // count total number of Keyword objects/records
    // there are ways to count without fetching all records, but this func is only used for testing
    static func count(context: NSManagedObjectContext) -> Int {
        var keywords: [Keyword]! = []

        let fetchRequest: NSFetchRequest<Keyword> = Keyword.fetchRequest()
        let predicateAll = NSPredicate(format: "TRUEPREDICATE")
        fetchRequest.predicate = predicateAll
        context.performAndWait {
            do {
                keywords = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("Failed to fetch all Keywords: \(error)", file: #fileID, line: #line)
            }
        }
        return keywords.count
    }

}
