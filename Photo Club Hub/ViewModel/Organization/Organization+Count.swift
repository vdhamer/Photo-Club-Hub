//
//  Organization+Count.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 28/11/2025.
//

import CoreData

extension Organization {

    static func count(context: NSManagedObjectContext, organizationTypeE: OrganizationTypeEnum) -> Int {

            let organizationCount: Int = context.performAndWait {

            let organizationType: OrganizationType =
            OrganizationType.findCreateUpdate(context: context,
                                              orgTypeName: organizationTypeE.unlocalizedSingular)
            let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
            let predicateFormat: String = "organizationType_ = %@" // avoid localization
            let predicate = NSPredicate(format: predicateFormat, argumentArray: [organizationType])
            fetchRequest.predicate = predicate

            do {
                return try context.fetch(fetchRequest).count
            } catch {
                ifDebugFatalError(
                    "Failed to fetch Organzations of type \(organizationType.organizationTypeName): \(error)",
                    file: #fileID, line: #line)
                return 0
            }
        }

        return organizationCount
    }
}
