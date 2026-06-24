//
//  Model.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 14/02/2025.
//

import CoreData // for NSManagedObject

/// Contains only method for deleting Core Data objects across various/all tables
public struct Model {

    /// Controls which entities `deleteAllCoreDataObjects` removes.
    public enum DeletionScope {
        case expertisesOnly // deletes Expertise, LocalizedExpertise, PhotographerExpertise only
        case standard       // avoids deleting Language, Organization, OrganizationType, LocalizedAddress
        case all            // deletes all objects from all CoreData tables
    }

    /// Deletes all relevant Core Data objects in order of dependencies to avoid issues with referential integrity.
    ///
    /// - Parameters:
    ///   - viewContext: The managed object context to operate on. For now this has to be the main thread.
    ///   - scope: Whether to preserve or also delete Organization, Language, and LocalizedAddress.
    @MainActor public static func deleteCoreDataObjects(viewContext: NSManagedObjectContext,
                                                        deletionScope: DeletionScope) {
        do {
            // order is important to avoid violating database referential integrity constraints
            try deleteEntitiesOfOneType("LocalizedExpertise", viewContext: viewContext)
            try deleteEntitiesOfOneType("PhotographerExpertise", viewContext: viewContext)
            try deleteEntitiesOfOneType("Expertise", viewContext: viewContext)
            if deletionScope == .expertisesOnly {
                try viewContext.save()
                return }

            try deleteEntitiesOfOneType("LocalizedRemark", viewContext: viewContext)
            try deleteEntitiesOfOneType("MemberPortfolio", viewContext: viewContext)
            try deleteEntitiesOfOneType("Photographer", viewContext: viewContext)

            if deletionScope == .all {
                // LocalizedAddress references both Organization and Language, so it must be deleted before either.
                try deleteEntitiesOfOneType("LocalizedAddress", viewContext: viewContext)
                try deleteEntitiesOfOneType("Organization", viewContext: viewContext)
                try deleteEntitiesOfOneType("OrganizationType", viewContext: viewContext)
                try deleteEntitiesOfOneType("Language", viewContext: viewContext)
            }

            try viewContext.save()
        } catch {
            ifDebugFatalError("Error during forced clearing of CoreData tables: \(error)")
        }
        if #available(iOS 18, macOS 15, *) { // uses Mutext feature of iOS 18
            Level1JsonReader.level1History.clear() // array used to avoiding cycles in level 1 "include" files
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
