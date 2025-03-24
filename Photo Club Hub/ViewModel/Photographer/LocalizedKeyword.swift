//
//  LocalizedKeyword.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 23/02/2025.
//

import CoreData // for NSManagedObjectContext

extension LocalizedKeyword {

    @available(*, unavailable)
    convenience init() {
        fatalError("init() is not available. Use .findCreateUpdate instead.")
    }

    // MARK: - getters (setting is done via findCreateUpdate)

    var keyword: Keyword { // getter
        if let keyword = keyword_ {
            return keyword
        } else {
            fatalError("Error because keyword is nil") // something is fundamentally wrong if this happens
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

    // Find existing Keyword object or create a new one.
    // Update existing attributes or fill the new object
    static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground or background context
                                 keyword: Keyword,
                                 language: Language,
                                 localizedName: String?,
                                 localizedUsage: String?
                                ) -> LocalizedKeyword {

        // execute fetchRequest to get keyword object for id=id. Query could return multiple keywords - but shouldn't.
        let fetchRequest: NSFetchRequest<LocalizedKeyword> = LocalizedKeyword.fetchRequest()
        let predicateFormat: String = "keyword_ = %@ AND language_ = %@" // avoid localization of query string
        fetchRequest.predicate = NSPredicate(format: predicateFormat, argumentArray: [keyword, language])

        var localizedKeywords: [LocalizedKeyword]! = []
        do {
            localizedKeywords = try context.fetch(fetchRequest)
        } catch {
            ifDebugFatalError("""
                              Failed to fetch LocalizedKeyword for \(keyword.id) \
                              in language \(language.isoCodeAllCaps): \(error)
                              """,
                              file: #fileID, line: #line) // on non-Debug version, continue with empty `keywords` array
        }

        // are there multiple translations of the keyword into the same language? This shouldn't be the case.
        if localizedKeywords.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("""
                              Query returned multiple (\(localizedKeywords.count)) translations \
                              of Keyword \(keyword.id) into \(language.isoCodeAllCaps)
                              """,
                              file: #fileID, line: #line)
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        // if a translation already exists, update non-identifying attributes
        if let localizedKeyword = localizedKeywords.first {
            if localizedKeyword.update(context: context, localizedName: localizedName, localizedUsage: localizedUsage) {
                print("""
                      Updated translation of keyword \"\(keyword.id)\" into \
                      \(language.isoCodeAllCaps) as \(localizedName ?? "nil")
                      """)
                LocalizedKeyword.save(context: context, errorText:
                                      """
                                      Could not update LocalizedKeyword for \"\(localizedKeyword.keyword.id)\" \
                                      for language \(localizedKeyword.language.isoCodeAllCaps)
                                      """,
                                      if: Settings.extraCoreDataSaves)
            }
            return localizedKeyword
        } else {
            let entity = NSEntityDescription.entity(forEntityName: "LocalizedKeyword", in: context)!
            let localizedKeyword = LocalizedKeyword(entity: entity, insertInto: context)
            localizedKeyword.name = localizedName // immediately set it to a non-nil value
            localizedKeyword.keyword_ = keyword
            localizedKeyword.language_ = language
            _ = localizedKeyword.update(context: context, localizedName: localizedName, localizedUsage: localizedUsage)
            LocalizedKeyword.save(context: context, errorText:
                                  """
                                  Could not create LocalizedKeyword for \"\(localizedKeyword.keyword.id)\" \
                                  for language \(localizedKeyword.language.isoCodeAllCaps)
                                  """,
                                  if: Settings.extraCoreDataSaves)
            return localizedKeyword
        }

     }

    // Update non-identifying attributes/properties within an existing instance of class LocalizedKeyword if needed.
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
                try context.save() // update modified properties of a Keyword object
             } catch {
                 ifDebugFatalError("""
                                   Update failed for LocalizedKeyword \
                                   (\(self.keyword.id) | \(self.language.isoCodeAllCaps))
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
                ifDebugFatalError(errorText ?? "Error saving LocalizedKeyword")
            }
        }
    }

    // count total number of objects in CoreData database
    static func count(context: NSManagedObjectContext) -> Int {
        var localizedKeywords: [LocalizedKeyword]! = []

        let fetchRequest: NSFetchRequest<LocalizedKeyword> = LocalizedKeyword.fetchRequest()
        let predicateAll = NSPredicate(format: "TRUEPREDICATE")
        fetchRequest.predicate = predicateAll

        context.performAndWait {
            do {
                localizedKeywords = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("Failed to fetch list of all LocalizedKeywords: \(error)",
                                  file: #fileID, line: #line)
                // on non-Debug version, continue with empty `keywords` array
            }
        }
        return localizedKeywords.count
    }

    // count number of objects with a given id
    static func count(context: NSManagedObjectContext, keywordID: String, languageIsoCode: String) -> Int {
        var localizedKeywords: [LocalizedKeyword]! = []

        let fetchRequest: NSFetchRequest<LocalizedKeyword> = LocalizedKeyword.fetchRequest()
        let predicateFormat: String = "keyword_.id_ = %@ && language_.isoCode_ = %@" // avoid localization
        fetchRequest.predicate = NSPredicate(format: predicateFormat, argumentArray: [keywordID, languageIsoCode])

        context.performAndWait {
            do {
                localizedKeywords = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("Failed to fetch LocalizedKeyword \(keywordID) for \(languageIsoCode): \(error)",
                                  file: #fileID, line: #line)
                // on non-Debug version, continue with empty `keywords` array
            }
        }
        return localizedKeywords.count
    }

}
