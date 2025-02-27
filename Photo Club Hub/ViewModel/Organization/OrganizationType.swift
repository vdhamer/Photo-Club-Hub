//
//  OrganizationType.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/12/2023.
//

import CoreData

extension OrganizationType {

    @available(*, unavailable)
    convenience init() {
        fatalError("init() is not available. Use .findCreateUpdate instead.")
    }

    @MainActor
    static func initConstants() { // called on main thread
        let viewContext = PersistenceController.shared.container.viewContext // requires foreground context

        for type in OrganizationTypeEnum.allCases { // type is simple enum
            _ = OrganizationType.findCreateUpdate( // organizationType is CoreData NSManagedObject
                context: viewContext, // requires @MainActor
                orgTypeName: type.unlocalizedSingular
            )
        }

        do {
            try viewContext.save() // persist all organizationTypes using main thread ManagedObjectContext
        } catch {
            viewContext.rollback()
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
    static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground or background context
                                 orgTypeName: String,
                                 unusedProperty: String = "foobar"
                                ) -> OrganizationType {

        let predicateFormat: String = "organizationTypeName_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat, argumentArray: [orgTypeName])
        let fetchRequest: NSFetchRequest<OrganizationType> = OrganizationType.fetchRequest()
        fetchRequest.predicate = predicate
        let organizationTypes: [OrganizationType] = (try? context.fetch(fetchRequest)) ?? [] // nil = absolute failure

        if organizationTypes.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("""
                              Query returned multiple (\(organizationTypes.count)) OrganizationTypes \
                              named \(orgTypeName)
                              """,
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        if let organizationType = organizationTypes.first { // already exists, so update non-identifying attributes
            if organizationType.update(context: context, unusedProperty: unusedProperty) {
                print("Updated info for organization type \"\(organizationType.organizationTypeName)\"")
                save(context: context, organizationType: organizationType, create: false)
            }
            return organizationType
        } else {
            // cannot use OrganizationType() initializer because we must use supplied context
            let entity = NSEntityDescription.entity(forEntityName: "OrganizationType", in: context)!
            let organizationType = OrganizationType(entity: entity, insertInto: context)
            organizationType.organizationTypeName = orgTypeName
            _ = organizationType.update(context: context, unusedProperty: unusedProperty)
            save(context: context, organizationType: organizationType, create: true)
            print("Created new OrganizationType called \"\(orgTypeName)\"")
            return organizationType
        }
    }

    // Update non-identifying attributes/properties within an existing instance of class OrganizationType
    fileprivate func update(context: NSManagedObjectContext,
                            unusedProperty: String) -> Bool {
        // OrganizationType doesn't have any non-identifying properties
        // So, to keep findCreateUpdate() and update() consistent across types, we added an unused one.

        var modified: Bool = false // dummy code because OrganizationType has only identifying properties

        if self.unusedProperty != unusedProperty {
            self.unusedProperty = unusedProperty
            modified = true
        }

        if modified {
            do {
                try context.save() // update modified properties of an OrganizationType object
             } catch {
                ifDebugFatalError("Update failed for OrganizationType \(organizationTypeName)",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, if save() fails, just continue
                modified = false
            }
        }

        return false // change to `return modified` if there is something to save
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

    fileprivate static func save(context: NSManagedObjectContext, organizationType: OrganizationType, create: Bool) {
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
            return String(localized: "clubs", table: "Package",
                          comment: "Mode for the Clubs page: show photo clubs as sections.")
        case .museum:
            return String(localized: "museums", table: "Package",
                          comment: "Mode for the Clubs page: show museums as sections.")
        default:
            return String(localized: "unknowns", table: "Package",
                          comment: "Organization type is not known. Used for debugging.")
        }
    }

    // used in Photo-Club-Hub-HTML
    static func randomClubMuseumUnknown() -> OrganizationTypeEnum { // used for testing purposes
        var generator = SystemRandomNumberGenerator()
        return .allCases.randomElement(using: &generator)! // .club, .museum or .unknown
    }

    // used (or not) in Photo-Club-Hub-HTML
    static func randomClubMuseum() -> OrganizationTypeEnum { // used for testing purposes
        if Bool.random() {
            return OrganizationTypeEnum.club
        } else {
            return OrganizationTypeEnum.museum
        }
    }
}
