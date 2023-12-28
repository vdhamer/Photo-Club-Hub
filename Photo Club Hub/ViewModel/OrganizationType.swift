//
//  OrganizationType.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/12/2023.
//

import CoreData

extension OrganizationType {

    private static var objectIDs: [OrganizationTypeEnum: NSManagedObjectID] = [:]

    static func initConstants() {
        guard Thread.isMainThread else { fatalError("OrganizationType.initConstants() must be on main thread") }
        guard OrganizationType.objectIDs.isEmpty else { fatalError("Repeated call to OrganizationalType.initConstants")}

        let persistenceController = PersistenceController.shared // for Core Data
        let viewContext = persistenceController.container.viewContext // foreground context

        for type in OrganizationTypeEnum.allCases { // type is simple enum
            let organizationType = OrganizationType.findCreateUpdate( // organizationType is CoreData NSManagedObject
                context: viewContext,
                name: type.unlocalizedSingular
            )
            OrganizationType.objectIDs[type] = organizationType.objectID // to access managed objects from bg threads
        }
    }

    // MARK: - getters and setters

    var name: String {
        get { return name_ ?? "Missing OrganizationType.name_" }
        set { name_ = newValue }
    }

    // MARK: - find or create

    // Find existing object or create a new object
    // Update existing attributes or fill the new object
    static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground of background context
                                 name: String
                                ) -> OrganizationType {

        let predicateFormat: String = "name_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat, argumentArray: [name])
        let fetchRequest: NSFetchRequest<OrganizationType> = OrganizationType.fetchRequest()
        fetchRequest.predicate = predicate
        let organizationTypes: [OrganizationType] = (try? context.fetch(fetchRequest)) ?? [] // nil = absolute failure

        if organizationTypes.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("Query returned multiple (\(organizationTypes.count)) OrganizationTypes named \(name)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        if let organizationType = organizationTypes.first { // already exists, so update non-identifying attributes
            print("Will try to update info for organization type \"\(organizationType.name)\"")
            if update(context: context, organizationType: organizationType, dummy: "dummy string #2") {
                print("Updated info for organization type \"\(organizationType.name)\"")
            }
            return organizationType
        } else {
            // cannot use OrganizationType() initializer because we must use bgContext
            let entity = NSEntityDescription.entity(forEntityName: "OrganizationType", in: context)!
            let organizationType = OrganizationType(entity: entity, insertInto: context)
            organizationType.name = name
            print("\(organizationType.name): Will try to create new OrganizationType")
            _ = update(context: context, organizationType: organizationType, dummy: "dummy string #1")
            print("\(organizationType.name): Created new OrganizationType called \"\(name)\"")
            return organizationType
        }
    }

    // Update non-identifying attributes/properties within existing instance of class OrganizationType
    static func update(context: NSManagedObjectContext, organizationType: OrganizationType, dummy: String) -> Bool {

        var modified: Bool = false

        if organizationType.dummy != dummy {
            organizationType.dummy = dummy
            modified = true
        }

        if modified {
            do {
                try context.save()
             } catch {
                ifDebugFatalError("Update failed for OrganizationType \(organizationType.name)",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, if save() fails, just continue
                return false
            }
        }
        return modified
    }

}

enum OrganizationTypeEnum: String, CaseIterable {

    case club // rawValue automatically set to "club"
    case museum

    var unlocalizedSingular: String {
        self.rawValue
    }

    var localizedPlural: String { // cannot simply using String(localized: unlocalizedString)
        switch self {
        case .club:
            return String(localized: "clubs",
                          comment: "Mode for the Clubs page: show photo clubs as sections.")
        case .museum:
            return String(localized: "musea",
                          comment: "Mode for the Clubs page: show musea as sections.")
        }
    }
}
