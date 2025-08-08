//
//  Model.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 14/02/2025.
//

import CoreData // for NSManagedObject

@MainActor
public struct Model {
    public static func deleteAllCoreDataObjects(viewContext: NSManagedObjectContext) {
        // order is important to avoid problems with referential integrity
        deleteCoreDataExpertisesAndLanguages(viewContext: viewContext) // performs its own save()
        deleteCoreDataPhotographersClubs(viewContext: viewContext) // performs its own save()
    }

    // don't delete Photographer before deleting this. See data model picture in README.md.
    private static func deleteCoreDataExpertisesAndLanguages(viewContext: NSManagedObjectContext) {
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

    // don't delete Photographer before deleting this. See data model picture in README.md.
    private static func deleteCoreDataPhotographersClubs(viewContext: NSManagedObjectContext) { // delete certain tables
        let forcedDataRefreshText = "Forced clearing of CoreData expertises "

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

    @MainActor
    private static func deleteEntitiesOfOneType(_ entity: String,
                                                viewContext: NSManagedObjectContext,
                                                retryDownCounter: Int = 5) throws {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                ifDebugFatalError("Could not save context before deleting \(entity)s.")
                return
            }
        }

        do {
            try viewContext.performAndWait {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
                fetchRequest.returnsObjectsAsFaults = false
                let results = try viewContext.fetch(fetchRequest)
                for object in results {
                    guard let objectData = object as? NSManagedObject else { continue }
                    viewContext.delete(objectData)
                }
                try viewContext.save()
                if entity == "OrganizationType" {
                    OrganizationType.initConstants()
                }
                if entity == "Language" {
                    Language.initConstants()
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
