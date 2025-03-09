//
//  Model.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 14/02/2025.
//

import CoreData // for NSManagedObject

@MainActor
struct Model {
    static func deleteAllCoreDataObjects(context: NSManagedObjectContext) {
        let forcedDataRefresh = "Forced refresh of CoreData data " // just for log, not localized

        // order is important because of non-optional relationships
        do { // order is important to avoid problems with referential integrity
            try deleteEntitiesOfOneType("LocalizedRemark", context: context)

            deleteCoreDataKeywords(context: context)

            try deleteEntitiesOfOneType("MemberPortfolio", context: context)
            try deleteEntitiesOfOneType("Organization", context: context)
            try deleteEntitiesOfOneType("Photographer", context: context)

            try deleteEntitiesOfOneType("OrganizationType", context: context)
            try deleteEntitiesOfOneType("Language", context: context)
            print(forcedDataRefresh + "was successful.")
            try context.save()
        } catch {
            ifDebugFatalError(forcedDataRefresh + "FAILED: \(error)")
        }
    }

    // don't delete Photographer or Language before deleting this. See data model picture in README.md.
    static func deleteCoreDataKeywords(context: NSManagedObjectContext) { // can be deleted separately if needed (Tests)
        let forcedDataRefresh = "Forced clearing of CoreData keywords "

        do { // order is important to avoid problems with referential integrity
            try deleteEntitiesOfOneType("LocalizedKeyword", context: context)
            try deleteEntitiesOfOneType("PhotographerKeyword", context: context)
            try deleteEntitiesOfOneType("Keyword", context: context)
            print(forcedDataRefresh + "was successful.")
            try? context.performAndWait {
                try context.save()
            }
        } catch {
            ifDebugFatalError(forcedDataRefresh + "FAILED: \(error)")
        }
    }

    // returns true if successful
    private static func deleteEntitiesOfOneType(_ entity: String, context: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false // comes from some fragment fron StackOverFlow? purpose?
        try? context.performAndWait {
            do {
                let results = try context.fetch(fetchRequest)
                for object in results {
                    guard let objectData = object as? NSManagedObject else {continue}
                    context.delete(objectData)
                }
                try context.save()
                // initConstants shouldn't be necessary, but is there as a temp safetynet for CoreData concurrenty issues
                if entity == "OrganizationType" {
                    OrganizationType.initConstants() // insert contant records into OrganizationType table if needed
                }
                if entity == "Language" { // initialization shouldn't be necessary (related to occasional transaction crash)
                    Language.initConstants() // insert contant records into OrganizationType table if needed
                }

            } catch let error { // if `entity` identifier is not found, `try` doesn't throw. Maybe a rethrow is missing.
                print("Delete all data in \(entity) error :", error)
                throw error
            }
        }
    }

}
