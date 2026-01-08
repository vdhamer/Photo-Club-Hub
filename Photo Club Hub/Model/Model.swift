//
//  Model.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 14/02/2025.
//

import CoreData // for NSManagedObject

/// Methods for deleting (all) Core Data objects per type
public struct Model {

    /// Deletes all relevant Core Data objects in the correct order to avoid issues with referential integrity.
    /// - Parameter viewContext: The managed object context to operate on. For now this has to be the main thread.
    @MainActor public static func deleteAllCoreDataObjects(viewContext: NSManagedObjectContext) {
        // order is important to avoid problems with referential integrity
        deleteCoreDataExpertisesAndLanguages(viewContext: viewContext) // performs its own save()
        deleteCoreDataPhotographersClubs(viewContext: viewContext) // performs its own save()
        if #available(iOS 18, macOS 15, *) {
            Level1JsonReader.level1History.clear()
        }
    }

    /// Deletes all Core Data objects related to expertises and languages.
    /// - Parameter viewContext: The managed object context to operate on. For now this has to be the main thread.
    @MainActor static func deleteCoreDataExpertisesAndLanguages(viewContext: NSManagedObjectContext) {
        let forcedDataRefresh = "Forced clearing of CoreData expertises "

        do { // order is important to avoid problems with referential integrity
            try deleteEntitiesOfOneType("LocalizedRemark", viewContext: viewContext)
            try deleteEntitiesOfOneType("LocalizedExpertise", viewContext: viewContext)
            try deleteEntitiesOfOneType("PhotographerExpertise", viewContext: viewContext)
            try deleteEntitiesOfOneType("Expertise", viewContext: viewContext)
            try deleteEntitiesOfOneType("Language", viewContext: viewContext)

            print(forcedDataRefresh + "was successful.")
        } catch {
            ifDebugFatalError(forcedDataRefresh + "FAILED: \(error)")
        }
    }

    /// Deletes all Core Data objects related to photographers and clubs.
    /// - Parameter viewContext: The managed object context to operate on. For now this has to be the main thread.
    @MainActor
    private static func deleteCoreDataPhotographersClubs(viewContext: NSManagedObjectContext) { // delete certain tables
        let forcedDataRefreshText = "Forced clearing of CoreData organizations "

        do { // order is important to avoid problems with referential integrity
            try deleteEntitiesOfOneType("MemberPortfolio", viewContext: viewContext)
            try deleteEntitiesOfOneType("Organization", viewContext: viewContext)
            try deleteEntitiesOfOneType("Photographer", viewContext: viewContext)

            try deleteEntitiesOfOneType("OrganizationType", viewContext: viewContext)

            print(forcedDataRefreshText + "was successful.")
        } catch {
            ifDebugFatalError(forcedDataRefreshText + "FAILED: \(error)")
        }
    }

    /// Deletes all objects of a given Core Data entity type, with optional retries on failure during save()..
    /// - Parameters:
    ///   - entity: The name of the entity to delete.
    ///   - viewContext: The managed object context to operate on. For now this has to be the main thread.
    ///   - retryDownCounter: The number of retries allowed in case of failure (default is 5).
    /// - Throws: An error if deletion ultimately fails despite retries.
    @MainActor private static func deleteEntitiesOfOneType(_ entity: String,
                                                           viewContext: NSManagedObjectContext,
                                                           retryDownCounter: Int = 5) throws {

        do {
            try viewContext.performAndWait {
                if viewContext.hasChanges {
                    do {
                        try viewContext.save()
                    } catch {
                        ifDebugFatalError("Could not save context before deleting \(entity)s.")
                        return
                    }
                }

                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                fetchRequest.returnsObjectsAsFaults = false
                let results = try viewContext.fetch(fetchRequest)
                for object in results {
                    guard let objectData = object as? NSManagedObject else { continue }
                    viewContext.delete(objectData)
                }
                try viewContext.save()
                switch entity {
                    case "OrganizationType": OrganizationType.initConstants(context: viewContext)
                    case "Language": Language.initConstants(context: viewContext)
                    default: break
                    }
            }
        } catch {
            viewContext.rollback()
            if retryDownCounter > 1 {
                sleep(1)
                print("deleteEntitiesOfOneType doing recursive retry #\(retryDownCounter) for entity \(entity)")
                return try self.deleteEntitiesOfOneType(entity,
                                                        viewContext: viewContext,
                                                        retryDownCounter: retryDownCounter-1)
            } else {
                print("Error deleting all data in \(entity):", error)
                throw error
            }
        }
    }

}
