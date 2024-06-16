//
//  OrganizationType.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/12/2023.
//

import CoreData

extension OrganizationType {

    @MainActor
    static func initConstants() { // called on main thread
        let viewContext = PersistenceController.shared.container.viewContext // requires foreground context

        for type in OrganizationTypeEnum.allCases { // type is simple enum
            _ = OrganizationType.findCreateUpdate( // organizationType is CoreData NSManagedObject
                context: viewContext, // requires @MainActor
                organizationTypeName: type.unlocalizedSingular
            )
        }

        do {
            try viewContext.save() // persist all organizationTypes using main thread ManagedObjectContext
        } catch {
            ifDebugFatalError("Couldn't initialize the three organizationType records",
                              file: #fileID, line: #line)
        }
    }

    // MARK: - getters and setters

    var organizationTypeName: String {
        get { return organizationTypeName_ ?? "Missing OrganizationType.name_" }
        set { organizationTypeName_ = newValue }
    }

    // MARK: - find or create

    // Find OrganizationType object (or create a new object - used at start of app)
    // Update existing attributes or fill the new object
    static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground of background context
                                 organizationTypeName: String
                                ) -> OrganizationType {

        let predicateFormat: String = "organizationTypeName_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat, argumentArray: [organizationTypeName])
        let fetchRequest: NSFetchRequest<OrganizationType> = OrganizationType.fetchRequest()
        fetchRequest.predicate = predicate
        let organizationTypes: [OrganizationType] = (try? context.fetch(fetchRequest)) ?? [] // nil = absolute failure

        if organizationTypes.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("""
                              Query returned multiple (\(organizationTypes.count)) OrganizationTypes \
                              named \(organizationTypeName)
                              """,
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        if let organizationType = organizationTypes.first { // already exists, so update non-identifying attributes
            if update(context: context, organizationType: organizationType) {
                print("Updated info for organization type \"\(organizationType.organizationTypeName)\"")
                save(context: context, organizationType: organizationType, create: false)
            }
            return organizationType
        } else {
            // cannot use OrganizationType() initializer because we must use supplied context
            let entity = NSEntityDescription.entity(forEntityName: "OrganizationType", in: context)!
            let organizationType = OrganizationType(entity: entity, insertInto: context)
            organizationType.organizationTypeName = organizationTypeName
            _ = update(context: context, organizationType: organizationType)
            save(context: context, organizationType: organizationType, create: true)
            print("Created new OrganizationType called \"\(organizationTypeName)\"")
            return organizationType
        }
    }

    // Update non-identifying attributes/properties within an existing instance of class OrganizationType
    private static func update(context: NSManagedObjectContext,
                               organizationType: OrganizationType /*, dummy dumby: String*/) -> Bool {

//        var modified: Bool = false // dummy code because OrganizationType has only identifying properties

//        if organizationType.dummy != dumby {
//            organizationType.dummy = dumby // think I saw debugger mix up param and property, so changed the name
//            modified = true
//        }

//        if modified {
//            do {
//                try context.save() // update modified properties of an OrganizationType object
//             } catch {
//                ifDebugFatalError("Update failed for OrganizationType \(organizationType.name)",
//                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
//                // in release mode, if save() fails, just continue
//                modified = false
//            }
//        }

        return false // change to `return modified` if there is something to modify
    }

    var isUnknown: Bool { // convenience function
        return self.organizationTypeName == OrganizationTypeEnum.unknown.rawValue
    }

    var isClub: Bool { // convenience function
        return self.organizationTypeName == OrganizationTypeEnum.club.rawValue
    }

    var isMuseum: Bool { // convenience function
        return self.organizationTypeName == OrganizationTypeEnum.museum.rawValue
    }

    private static func save(context: NSManagedObjectContext, organizationType: OrganizationType, create: Bool) {
        do {
            try context.save()
        } catch {
            if create {
                ifDebugFatalError("Could not save created OrganizationType \(organizationType.organizationTypeName)")
            } else {
                ifDebugFatalError("""
                                  Could not save updated property of OrganizationType \
                                  \(organizationType.organizationTypeName)
                                  """)
            }
        }
    }

}

enum OrganizationTypeEnum: String, CaseIterable, Sendable, Hashable {

    case club // rawValue automatically set to "club"
    case museum
    case unknown

    var unlocalizedSingular: String { // "museum" as passed around using `OrganizationType.name: String`
        self.rawValue
    }

    var unlocalizedPlural: String {
        self.rawValue + "s" // "museums" as used in parsing root.level1.json file
    }

    var localizedPlural: String { // "musea" as used in user interface (e.g. NavigationBar.title)
        switch self {
        case .club:
            return String(localized: "clubs", // can't convert using unlocalizedSingular because of type isues
                          comment: "Mode for the Clubs page: show photo clubs as sections.")
        case .museum:
            return String(localized: "museums",
                          comment: "Mode for the Clubs page: show museums as sections.")
        default:
            return String(localized: "unknowns",
                          comment: "Organization type is not known. Used for debugging.")
        }
    }
}
