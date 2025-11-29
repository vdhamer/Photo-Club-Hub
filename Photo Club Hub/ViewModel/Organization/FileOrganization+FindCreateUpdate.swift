//
//  FileOrganization+FindCreateUpdate.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 28/11/2025.
//

import CoreData // for Core Data access
import CoreLocation // for CLLocationCoordinate2D

extension Organization {

    @available(*, unavailable)
    convenience init() {
        fatalError("init() is not available. Use .findCreateUpdate instead.")
    }

    // Find existing organization or create a new one
    // Update new or existing organization's attributes
    public static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground or background context
                                        organizationTypeEnum: OrganizationTypeEnum,
                                        idPlus: OrganizationIdPlus,
                                        coordinates: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0),
                                        removeOrganization: Bool = false, // can remove records for removed org's
                                        optionalFields: OrganizationOptionalFields = OrganizationOptionalFields(),
                                        pinned: Bool = false) -> Organization {

        let predicateFormat: String = "fullName_ = %@ AND town_ = %@" // avoid localization
        // Note that organizationType is not an identifying attribute.
        // This implies that you cannot have 2 organizations with the same Name and Town, but of a different type.
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [idPlus.fullName,
                                                    idPlus.town] )
        let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
        fetchRequest.predicate = predicate
        let organizations: [Organization] = (try? context.fetch(fetchRequest)) ?? []

        if organizations.count > 1 { // organization exists, but there shouldn't be multiple that satify the predicate
            ifDebugFatalError("Query returned \(organizations.count) organizations named " +
                              "\(idPlus.fullName) in \(idPlus.town)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        if let organization = organizations.first { // already exists, so make sure non-ID attributes are up to date
            print("\(organization.fullNameTown): Will try to update info for organization \(organization.fullName)")
            if organization.update(bgContext: context,
                                   organizationTypeEnum: organizationTypeEnum,
                                   nickName: idPlus.nickname,
                                   coordinates: coordinates,
                                   removeOrganization: removeOrganization,
                                   optionalFields: optionalFields,
                                   pinned: pinned) {
                print("""
                  \(organization.fullNameTown): Successfully updated existing organization \(organization.fullName)
                  """)
            }
            return organization
        } else { // have to create PhotoClub object because it doesn't exist yet
            // cannot use PhotoClub() initializer because we must use bgContext
            let entity = NSEntityDescription.entity(forEntityName: "Organization", in: context)!
            let organization = Organization(entity: entity, insertInto: context) // create new Club or Museum
            organization.fullName = idPlus.fullName // first part of ID
            organization.town = idPlus.town // second part of ID
            // some fancy footwork because organization type info originated from other context
            let organizationType = OrganizationType.findCreateUpdate(context: context,
                                                                     orgTypeName: organizationTypeEnum.rawValue)
            organization.organizationType = organizationType
            print("\(organization.fullNameTown): Will try to fill fields for this new organization")
            _ = organization.update(bgContext: context,
                                    organizationTypeEnum: organizationTypeEnum,
                                    nickName: idPlus.nickname,
                                    coordinates: coordinates,
                                    removeOrganization: removeOrganization,
                                    optionalFields: optionalFields,
                                    pinned: pinned)
            print("\(organization.fullNameTown): Successfully created new \(organizationTypeEnum.rawValue)")
            return organization
        }
    }

    // Update non-identifying attributes/properties within existing instance of class Organization
    // swiftlint:disable:next function_parameter_count cyclomatic_complexity function_body_length
    private func update(bgContext: NSManagedObjectContext,
                        organizationTypeEnum: OrganizationTypeEnum,
                        nickName: String,
                        coordinates: CLLocationCoordinate2D,
                        removeOrganization: Bool, // used to remove records for org's that disappeared
                        optionalFields: OrganizationOptionalFields,
                        pinned: Bool) -> Bool {

        var modified: Bool = false

        if self.nickName_  == nil, self.nickName_ != nickName {
            self.nickName_ = nickName
            modified = true }

        // allow small rouding differences in double (instead of using != for Doubles)
        let delta = abs(self.latitude_ - coordinates.latitude) +
                    abs(self.longitude_ - coordinates.longitude)
        if delta > 0.000001 {
            self.longitude_ = coordinates.longitude
            self.latitude_ = coordinates.latitude
            modified = true }

        if self.removeOrganization != removeOrganization {
            self.removeOrganization = removeOrganization
            modified = true }

        if let website = optionalFields.organizationWebsite, self.organizationWebsite != website {
            self.organizationWebsite = website
            modified = true }

        if let level2URL = optionalFields.level2URL, self.level2URL_ != level2URL {
            self.level2URL_ = level2URL
            modified = true }

        if let wikiURL = optionalFields.wikipedia, self.wikipedia != wikiURL {
            self.wikipedia = wikiURL
            modified = true }

        if let contactEmail = optionalFields.contactEmail, self.contactEmail != contactEmail {
            self.contactEmail = contactEmail
            modified = true }

        if let fotobondNumber = optionalFields.fotobondNumber, self.fotobondNumber != fotobondNumber {
            self.fotobondNumber = fotobondNumber
            modified = true }

        if self.pinned != pinned {
            self.pinned = pinned
            modified = true }

        for localizedRemark in optionalFields.localizedRemarks { // load JSON localizedRemarks for provided languages
            let isoCode: String? = localizedRemark["language"].stringValue.uppercased() // e.g. "NL", "DE" or "PDC"
            let localizedRemarkNewValue: String? = localizedRemark["value"].stringValue

            if isoCode != nil && localizedRemarkNewValue != nil { // nil could occur if JSON file isn't schema compliant
                let language = Language.findCreateUpdate(context: bgContext,
                                                         isoCode: isoCode!) // find or construct the remark's Language
                // language updates doesn't set modified flag

                let remarkNeedsPersisting: Bool = LocalizedRemark.findCreateUpdate(
                    bgContext: bgContext, // create object
                    organization: self,
                    language: language,
                    localizedString: localizedRemarkNewValue!
                )
                if remarkNeedsPersisting { modified = true }
            }
        } // end of loop over remark in all provided languages

        if bgContext.hasChanges {
            do {
                try bgContext.save() // persist modifications in PhotoClub record
            } catch {
                print("Error: \(error)")
                ifDebugFatalError("Update failed for organization \"\(fullName)\"",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, if .save() fails, just continue
                return false
            }
        }
        return modified
    }

    public static func find(context: NSManagedObjectContext, // can be foreground or background context
                            organizationID: OrganizationID) throws -> Organization {

        let predicateFormat: String = "fullName_ = %@ AND town_ = %@" // avoid localization
        // Note that organizationType is not an identifying attribute.
        // This implies that you cannot have 2 organizations with the same Name and Town, but of a different type.
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [organizationID.fullName, organizationID.town] )
        let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
        fetchRequest.predicate = predicate
        let organizations: [Organization] = (try? context.fetch(fetchRequest)) ?? []

        if organizations.count > 1 { // organization exists, but there shouldn't be multiple that satify the predicate
            ifDebugFatalError("Query returned \(organizations.count) organizations named " +
                              "\(organizationID.fullName) in \(organizationID.town)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

        if let org = organizations.first {
            return org
        } else {
            throw CoreDataError.cantFindOrg(
                "No organization found matching \(organizationID.fullName) in \(organizationID.town)")
        }
    }

    fileprivate enum CoreDataError: Error {
        case cantFindOrg(_ message: String)
    }

}
