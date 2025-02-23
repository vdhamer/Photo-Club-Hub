//
//  Keyword.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 19/02/2025.
//

import CoreData // for NSManagedObjectContext

extension Keyword {

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
    fileprivate static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground of background context
                                             id: String,
                                             isStandard: Bool
                                            ) -> Keyword {

        // execute fetchRequest to get keyword object for id=id. Query could return more than 1.
        let predicateFormat: String = "id_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat, argumentArray: [id])
        let fetchRequest: NSFetchRequest<Keyword> = Keyword.fetchRequest()
        fetchRequest.predicate = predicate
        var keywords: [Keyword]! = []
        do {
            keywords = try context.fetch(fetchRequest)
        } catch {
            ifDebugFatalError("Failed to fetch Keyword \(id): \(error)", file: #fileID, line: #line)
            // on non-Debug version, continue with empty `keywords` array
        }

        if keywords.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("Query returned multiple (\(keywords.count)) Keywords with code \(id)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        if let keyword = keywords.first { // already exists, so update non-identifying attributes
            if keyword.update(context: context, isStandard: isStandard) {
                print("Updated info for keyword \"\(keyword.id)\" that became \(isStandard ? "" : "non-")standard")
                if Settings.extraCoreDataSaves {
                    save(context: context, keyword: keyword, create: false)
                }
            }
            return keyword
        } else {
            // cannot use Language() initializer because we must use supplied context
            let entity = NSEntityDescription.entity(forEntityName: "Keyword", in: context)!
            let keyword = Keyword(entity: entity, insertInto: context)
            keyword.id = id // immediately set it to a non-nil value
            _ = keyword.update(context: context, isStandard: isStandard) // ignore whether update made changes
            if Settings.extraCoreDataSaves {
                save(context: context, keyword: keyword, create: true)
            }
            print("Created new Keyword for \"\(keyword.id)\"")
            return keyword
        }

    }

    // count number of objects with a given id
    static func count(context: NSManagedObjectContext, id: String) -> Int {
        var keywords: [Keyword]! = []

        let fetchRequest: NSFetchRequest<Keyword> = Keyword.fetchRequest()
        let predicateFormat: String = "id_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat, argumentArray: [id])
        fetchRequest.predicate = predicate
        do {
            keywords = try context.fetch(fetchRequest)
        } catch {
            ifDebugFatalError("Failed to fetch Keyword \(id): \(error)", file: #fileID, line: #line)
            // on non-Debug version, continue with empty `keywords` array
        }
        return keywords.count
    }

    // Find existing non-standard Keyword object or create a new one.
    // Update existing attributes or fill the new object
    static func findCreateUpdateStandard(context: NSManagedObjectContext, // can be foreground of background context
                                         id: String
                                        ) -> Keyword {
        findCreateUpdate(context: context, id: id, isStandard: true)
    }

    // Find existing non-standard Keyword object or create a new one.
    // Update existing attributes or fill the new object
    static func findCreateUpdateNonStandard(context: NSManagedObjectContext, // can be foreground of background context
                                            id: String
                                           ) -> Keyword {
        findCreateUpdate(context: context, id: id, isStandard: false)
    }

    // Update non-identifying attributes/properties within an existing instance of class Keyword if needed.
    // Returns whether an update was needed.
    fileprivate func update(context: NSManagedObjectContext,
                            isStandard: Bool) -> Bool {

        var modified: Bool = false

        if self.isStandard != isStandard {
            self.isStandard = isStandard
            modified = true
        }

        if modified && Settings.extraCoreDataSaves {
            do {
                try context.save() // update modified properties of a Keyword object
             } catch {
                 ifDebugFatalError("Update failed for Keyword \"\(id)\"",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, if save() fails, just continue
            }
        }

        return modified
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

    static func save(context: NSManagedObjectContext, keyword: Keyword, create: Bool) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                if create {
                    ifDebugFatalError("Could not save created Keyword \"\(keyword.id)\"")
                } else {
                    ifDebugFatalError("Could not save updated property of Keyword \"\(keyword.id)\"")
                }
            }
        }
    }

}
