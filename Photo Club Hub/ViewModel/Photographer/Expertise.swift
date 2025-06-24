//
//  Expertise.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 19/02/2025.
//

import CoreData // for NSManagedObjectContext
import SwiftyJSON // for JSON()

extension Expertise {

    @available(*, unavailable)
    convenience init() {
        fatalError("init() is not available. Use .findCreateUpdate instead.")
    }

    // MARK: - getters and setters

    // `id` is persisted in CoreData as `id_` but has to be public because it is also used for the Identifiable protocol
    public var id: String {
        get {
            if id_ != nil { // shouldn't be nil in the first place
                return id_!
            } else {
                ifDebugFatalError("CoreData id_ for Expertise is nil", file: #fileID, line: #line)
                return "No id for Expertise"
            }
        }
        set {
            id_ = newValue.capitalized // ensure CoreData always contains string with first letter capitalized
        }
    }

    // MARK: - find or create

    // Find existing Expertise object or create a new one.
    // Update existing attributes or fill the new object
    fileprivate static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground or background context
                                             id: String,
                                             isStandard: Bool?, // nil means don't change existing value
                                             name: [JSON], // JSON equivalent of a dictionary with localized names
                                             usage: [JSON]
                                            ) -> Expertise {

        // execute fetchRequest to get expertise object for id=id. Query could return multiple - but shouldn't.
        let fetchRequest: NSFetchRequest<Expertise> = Expertise.fetchRequest()
        let predicateFormat: String = "id_ = %@" // avoid localization
        fetchRequest.predicate = NSPredicate(format: predicateFormat, argumentArray: [id])

        var expertises: [Expertise]! = []
        do {
            expertises = try context.fetch(fetchRequest)
        } catch {
            ifDebugFatalError("Failed to fetch Expertise \(id): \(error)", file: #fileID, line: #line)
            // on non-Debug version, continue with empty `expertises` array
        }

        // are there multiple copies of the expertise? This shouldn't be the case.
        if expertises.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugPrint("Query returned multiple (\(expertises.count)) Expertises with code \(id)")
        }

        if let expertise = expertises.first { // already exists, so update non-identifying attributes
            if expertise.update(context: context, isStandard: isStandard, name: name, usage: usage) {
                if isStandard == nil {
                    ifDebugFatalError("Updated expertise \(expertise.id).isStandard to nil (which is suspicious)")
                } else {
                    print("Updated expertise \(expertise.id).isStandard to \(isStandard! ? "" : "non-")standard")
                }
                if Settings.extraCoreDataSaves {
                    Expertise.save(context: context, errorText: "Could not update Expertise \"\(expertise.id)\"")
                }
            }
            return expertise
        } else {
            // cannot use Expertise() initializer because we must use supplied context
            let entity = NSEntityDescription.entity(forEntityName: "Expertise", in: context)!
            let expertise = Expertise(entity: entity, insertInto: context)
            expertise.id = id // immediately set it to a non-nil value
            _ = expertise.update(context: context,
                               isStandard: isStandard,
                               name: name, // ignore whether update made changes
                               usage: usage)
            if Settings.extraCoreDataSaves {
                Expertise.save(context: context, errorText: "Could not save Expertise \"\(expertise.id)\"")
            }
            print("Created new Expertise called \"\(expertise.id)\"")
            return expertise
        }

    }

    // Find existing standard Expertise object or create a new one.
    // Update existing attributes or fill the new object
    public static func findCreateUpdateStandard(context: NSManagedObjectContext, // can be foreground or background
                                                id: String,
                                                name: [JSON], // array mapping languages to localizedNames
                                                usage: [JSON]
    					       ) -> Expertise {
        findCreateUpdate(context: context, id: id, isStandard: true, name: name, usage: usage)
    }

    // Find existing non-standard Expertise object or create a new one.
    // Update existing attributes or fill the new object
    public static func findCreateUpdateNonStandard(context: NSManagedObjectContext, // can be foreground or background
                                                   id: String,
                                                   name: [JSON], // array mapping languages to localizedNames
                                                   usage: [JSON]
    						  ) -> Expertise {
        findCreateUpdate(context: context, id: id, isStandard: false, name: name, usage: usage)
    }

    // Find existing Expertise object or create a new one without changing the Standard flag.
    // Don't update existing Standard attribute
    static func findCreateUpdateUndefStandard(context: NSManagedObjectContext, // can be foreground or background
                                              id: String,
                                              name: [JSON], // array mapping languages to localizedNames
                                              usage: [JSON]
                                             ) -> Expertise {
        findCreateUpdate(context: context, id: id, isStandard: nil, name: name, usage: usage)
    }

    // Update non-identifying attributes/properties within an existing instance of class Expertise if needed.
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

        for localizedExpertise in name {
            guard localizedExpertise["language"].exists(), localizedExpertise["localizedString"].exists()
                else { continue }

            let isoCode: String = localizedExpertise["language"].string!
            let language = Language.findCreateUpdate(context: context, isoCode: isoCode)

            let localizedString: String = localizedExpertise["localizedString"].string!
            _ = LocalizedExpertise.findCreateUpdate(context: context,
                                                    expertise: self, language: language,
                                                    localizedName: localizedString, localizedUsage: nil)
        }

        for localizedUsage in usage {
            guard localizedUsage["language"].exists(), localizedUsage["localizedString"].exists() else { continue }

            let isoCode: String = localizedUsage["language"].string!
            let language = Language.findCreateUpdate(context: context, isoCode: isoCode)

            let localizedDescription: String = localizedUsage["localizedString"].string!
            _ = LocalizedExpertise.findCreateUpdate(context: context,
                                                    expertise: self, language: language,
                                                    localizedName: nil, localizedUsage: localizedDescription)

        }

        if updated && Settings.extraCoreDataSaves {
            do {
                try context.save() // update modified properties of a Expertise object
            } catch {
                ifDebugFatalError("Update failed for Expertise \"\(id)\"",
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
            ifDebugFatalError("Could not save the deletion of Expertise \"\(self.id)\"")
        }
    }

    static func save(context: NSManagedObjectContext, errorText: String? = nil) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                ifDebugFatalError(errorText ?? "Error saving Expertise")
            }
        }
    }

    // count number of Expertises with a given id
    static func count(context: NSManagedObjectContext, expertiseID: String) -> Int {
        var expertises: [Expertise]! = []

        context.performAndWait {
            let fetchRequest: NSFetchRequest<Expertise> = Expertise.fetchRequest()
            let predicateFormat: String = "id_ = %@" // avoid localization
            let predicate = NSPredicate(format: predicateFormat, argumentArray: [expertiseID])
            fetchRequest.predicate = predicate
            do {
                expertises = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("Failed to fetch Expertise \(expertiseID): \(error)", file: #fileID, line: #line)
            }
        }
        return expertises.count
    }

    // count total number of Expertise objects/records
    // there are ways to count without fetching all records, but this func is only used for testing
    static func count(context: NSManagedObjectContext) -> Int {
        var expertises: [Expertise]! = []

        context.performAndWait {
            let fetchRequest: NSFetchRequest<Expertise> = Expertise.fetchRequest()
            let predicateAll = NSPredicate(format: "TRUEPREDICATE")
            fetchRequest.predicate = predicateAll

            do {
                expertises = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("Failed to fetch all Expertises: \(error)", file: #fileID, line: #line)
            }
        }

        return expertises.count
    }

    @MainActor
    // get array with list of all Expertises
    static func getAll(context: NSManagedObjectContext) -> [Expertise] {
        var expertises: [Expertise]! = []

        context.performAndWait {
            let fetchRequest: NSFetchRequest<Expertise> = Expertise.fetchRequest()
            let predicateAll = NSPredicate(format: "TRUEPREDICATE")
            fetchRequest.predicate = predicateAll
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id_", ascending: true)]

            do {
                expertises = try context.fetch(fetchRequest)
            } catch {
                ifDebugFatalError("Failed to fetch all Expertises: \(error)", file: #fileID, line: #line)
            }
        }

        return expertises
    }

    var localizedExpertises: Set<LocalizedExpertise> {
        (localizedExpertises_ as? Set<LocalizedExpertise>) ?? []
    }

    // Priority system to choose the most appropriate LocalizedExpertise for a given Expertise.
    // The choice depends on available translations and the current language preferences set on the device.
    public var selectedLocalizedExpertise: LocalizedExpertiseResult {
        // don't use Locale.current.language.languageCode because this only returns languages supported by the app
        // first choice: accomodate user's language preferences according to Apple's Locale API
        for lang in Locale.preferredLanguages {
            let langID = lang.split(separator: "-").first?.uppercased() ?? "EN"
            // now check if one of the user's preferences is available for this Remark
            for localizedExpertise in localizedExpertises where localizedExpertise.language.isoCodeAllCaps == langID {
                return LocalizedExpertiseResult(localizedExpertise: localizedExpertise, id: self.id)
            }
        }

        // second choice: most people speak English, at least let's pretend that is the case ;-)
        for localizedExpertise in localizedExpertises where localizedExpertise.language.isoCodeAllCaps == "EN" {
            return LocalizedExpertiseResult(localizedExpertise: localizedExpertise, id: self.id)
        }

        // third choice: use arbitrary (first) translation available for this expertise
        if localizedExpertises.first != nil {
            return LocalizedExpertiseResult(localizedExpertise: localizedExpertises.first!, id: self.id)
        }

        return LocalizedExpertiseResult(localizedExpertise: nil, id: self.id)
    }

}
