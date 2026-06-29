//
//  OrganizationTypeTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 29/06/2026.
//

import Testing
@testable import Photo_Club_Hub
import CoreData // for NSManagedObjectContext

@MainActor @Suite("Tests the Core Data OrganizationType class") struct OrganizationTypeTests {

    private let viewContext: NSManagedObjectContext

    init () {
        viewContext = PersistenceController.shared.container.viewContext
    }

    // Counts OrganizationType records matching the given (identifying) type name.
    private func count(_ orgTypeName: String) -> Int {
        let predicate = NSPredicate(format: "organizationTypeName_ = %@", argumentArray: [orgTypeName])
        let fetchRequest: NSFetchRequest<OrganizationType> = OrganizationType.fetchRequest()
        fetchRequest.predicate = predicate
        return ((try? viewContext.fetch(fetchRequest)) ?? []).count
    }

    // Calling findCreateUpdate twice with the same type name must return the same object (no duplicate).
    @Test("findCreateUpdate is idempotent for a given type name") func idempotentForSameName() {
        let orgTypeName = "unittest-" + String.random(length: 10) // avoid clashing with seeded club/museum/unknown

        let type1 = OrganizationType.findCreateUpdate(context: viewContext, orgTypeName: orgTypeName)
        let type2 = OrganizationType.findCreateUpdate(context: viewContext, orgTypeName: orgTypeName)

        #expect(type1 === type2) // same managed object, not a second copy
        #expect(type1.organizationTypeName == orgTypeName)
        #expect(count(orgTypeName) == 1) // exactly one record exists for this name
    }

}
