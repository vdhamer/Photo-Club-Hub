//
//  Model.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 14/02/2025.
//

import CoreData // for NSManagedObject

struct Model {
    @MainActor
    static func deleteAllCoreDataObjects() {
        let forcedDataRefresh = "Forced refresh of CoreData data performed" // just for log, not localized

        // order is important because of non-optional relationships
        do {
            try deleteEntitiesOfOneType("LocalizedRemark")
            try deleteEntitiesOfOneType("LocalizedKeyword")
            try deleteEntitiesOfOneType("Language")

            try deleteEntitiesOfOneType("PhotographerKeyword")
            try deleteEntitiesOfOneType("Keyword")

            try deleteEntitiesOfOneType("MemberPortfolio")
            try deleteEntitiesOfOneType("Organization")
            try deleteEntitiesOfOneType("Photographer")

            try deleteEntitiesOfOneType("OrganizationType")
            print(forcedDataRefresh + " successfully.")
        } catch {
            print(forcedDataRefresh + " UNsuccessfully.")
        }
    }

    // returns true if successful
    @MainActor
    private static func deleteEntitiesOfOneType(_ entity: String) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let viewContext = PersistenceController.shared.container.viewContext // requires @MainActor
            let results = try viewContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                viewContext.delete(objectData)
            }
            try viewContext.save()
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
