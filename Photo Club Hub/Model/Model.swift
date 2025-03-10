//
//  Model.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 14/02/2025.
//

import CoreData // for NSManagedObject

struct Model {
    static func deleteAllCoreDataObjects(context: NSManagedObjectContext) async {
        let forcedDataRefresh = "Forced refresh of CoreData data " // just for log, not localized

        // order is important because of non-optional relationships
        do { // order is important to avoid problems with referential integrity
            try await deleteEntitiesOfOneType("LocalizedRemark", context: context)

            await deleteCoreDataKeywords(context: context)

            try await deleteEntitiesOfOneType("MemberPortfolio", context: context)
            try await deleteEntitiesOfOneType("Organization", context: context)
            try await deleteEntitiesOfOneType("Photographer", context: context)

            try await deleteEntitiesOfOneType("OrganizationType", context: context)
            try await deleteEntitiesOfOneType("Language", context: context)
            print(forcedDataRefresh + "was successful.")
            try context.performAndWait {
                try context.save()
            }
        } catch {
            ifDebugFatalError(forcedDataRefresh + "FAILED: \(error)")
        }
    }

    // don't delete Photographer or Language before deleting this. See data model picture in README.md.
    static func deleteCoreDataKeywords(context: NSManagedObjectContext) async { // delete subset of tables eparately
        let forcedDataRefresh = "Forced clearing of CoreData keywords "

        do { // order is important to avoid problems with referential integrity
            try await deleteEntitiesOfOneType("LocalizedKeyword", context: context)
            try await deleteEntitiesOfOneType("PhotographerKeyword", context: context)
            try await deleteEntitiesOfOneType("Keyword", context: context)
            print(forcedDataRefresh + "was successful.")
            try context.performAndWait {
                try context.save()
            }
        } catch {
            ifDebugFatalError(forcedDataRefresh + "FAILED: \(error)")
        }
    }

    // returns true if successful
    private static func deleteEntitiesOfOneType(_ entity: String, context: NSManagedObjectContext) async throws {
        do {
            try await context.perform {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                fetchRequest.returnsObjectsAsFaults = false // comes from some fragment fron StackOverFlow? purpose?
                let results = try context.fetch(fetchRequest)
                for object in results {
                    guard let objectData = object as? NSManagedObject else {continue}
                    context.delete(objectData)
                }
                try context.save()
                // initConstants shouldn't be needed, but is there as a temp safetynet for CoreData concurrency issues
                if entity == "OrganizationType" {
                    OrganizationType.initConstants() // insert contant records into OrganizationType table if needed
                }
                if entity == "Language" {
                    Language.initConstants() // insert contant records into OrganizationType table if needed
                }
            }
        } catch {
            print("Delete all data in \(entity) error :", error)
            throw error
        }
    }

}
