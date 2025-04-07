//
//  Keyword.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 19/02/2025.
//

import CoreData // for NSManagedObjectContext
import SwiftyJSON // for JSON()

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
                                             isStandard: Bool?, // nil means don't change existing value
                                             name: [JSON], // JSON equivalent of a dictionary with localized names
                                             usage: [JSON]
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
            ifDebugPrint("Query returned multiple (\(keywords.count)) Keywords with code \(id)")
        }

        if let keyword = keywords.first { // already exists, so update non-identifying attributes
            if keyword.update(context: context, isStandard: isStandard, name: name, usage: usage) {
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
            _ = keyword.update(context: context,
                               isStandard: isStandard,
                               name: name, // ignore whether update made changes
                               usage: usage)
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
                                         id: String,
                                         name: [JSON], // array mapping languages to localizedNames
                                         usage: [JSON]
                                        ) -> Keyword {
        findCreateUpdate(context: context, id: id, isStandard: true, name: name, usage: usage)
    }

    // Find existing non-standard Keyword object or create a new one.
    // Update existing attributes or fill the new object
    static func findCreateUpdateNonStandard(context: NSManagedObjectContext, // can be foreground or background context
                                            id: String,
                                            name: [JSON], // array mapping languages to localizedNames
                                            usage: [JSON]
                                           ) -> Keyword {
        findCreateUpdate(context: context, id: id, isStandard: false, name: name, usage: usage)
    }

    // Find existing Keyword object or create a new one without changing the Standard flag.
    // Don't update existing Standard attribute
    static func findCreateUpdateUndefStandard(context: NSManagedObjectContext, // can be foreground or background cntxt
                                              id: String,
                                              name: [JSON], // array mapping languages to localizedNames
                                              usage: [JSON]
                                             ) -> Keyword {
        findCreateUpdate(context: context, id: id, isStandard: nil, name: name, usage: usage)
    }

    // Update non-identifying attributes/properties within an existing instance of class Keyword if needed.
    // Returns whether an update was needed.
    fileprivate func update(context: NSManagedObjectContext,
                            isStandard: Bool?, // nil means don't change
                            name: [JSON], // empty array means do not change
                            usage: [JSON]
    ) -> Bool {

        var updated: Bool = false

        if isStandard != nil, self.isStandard != isStandard {
            self.isStandard = isStandard!
            updated = true
        }

        for localizedKeyword in name {
            guard localizedKeyword["language"].exists(), localizedKeyword["localizedString"].exists() else { continue }

            let isoCode: String = localizedKeyword["language"].string!
            let language = Language.findCreateUpdate(context: context, isoCode: isoCode)

            let localizedString: String = localizedKeyword["localizedString"].string!
            _ = LocalizedKeyword.findCreateUpdate(context: context,
                                                  keyword: self, language: language,
                                                  localizedName: localizedString, localizedUsage: nil)
        }

        for localizedUsage in usage {
            guard localizedUsage["language"].exists(), localizedUsage["localizedString"].exists() else { continue }

            let isoCode: String = localizedUsage["language"].string!
            let language = Language.findCreateUpdate(context: context, isoCode: isoCode)

            let localizedDescription: String = localizedUsage["localizedString"].string!
            _ = LocalizedKeyword.findCreateUpdate(context: context,
                                                  keyword: self, language: language,
                                                  localizedName: nil, localizedUsage: localizedDescription)

        }

        if updated && Settings.extraCoreDataSaves {
            do {
                try context.save() // update modified properties of a Keyword object
            } catch {
                ifDebugFatalError("Update failed for Keyword \"\(id)\"",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, if save() fails, just continue
            }
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

        context.performAndWait {
            let fetchRequest: NSFetchRequest<Keyword> = Keyword.fetchRequest()
            let predicateFormat: String = "id_ = %@" // avoid localization
            let predicate = NSPredicate(format: predicateFormat, argumentArray: [keywordID])
            fetchRequest.predicate = predicate
            do {
                keywords = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("Failed to fetch Keyword \(keywordID): \(error)", file: #fileID, line: #line)
            }
        }
        return keywords.count
    }

    // count total number of Keyword objects/records
    // there are ways to count without fetching all records, but this func is only used for testing
    static func count(context: NSManagedObjectContext) -> Int {
        var keywords: [Keyword]! = []

        context.performAndWait {
            let fetchRequest: NSFetchRequest<Keyword> = Keyword.fetchRequest()
            let predicateAll = NSPredicate(format: "TRUEPREDICATE")
            fetchRequest.predicate = predicateAll

            do {
                keywords = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("Failed to fetch all Keywords: \(error)", file: #fileID, line: #line)
            }
        }

        return keywords.count
    }

    @MainActor
    // get array with list of all Keywords
    static func getAll(context: NSManagedObjectContext) -> [Keyword] {
        var keywords: [Keyword]! = []

        context.performAndWait {
            let fetchRequest: NSFetchRequest<Keyword> = Keyword.fetchRequest()
            let predicateAll = NSPredicate(format: "TRUEPREDICATE")
            fetchRequest.predicate = predicateAll
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id_", ascending: true)]

            do {
                keywords = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("Failed to fetch all Keywords: \(error)", file: #fileID, line: #line)
            }
        }

        return keywords
    }

}
