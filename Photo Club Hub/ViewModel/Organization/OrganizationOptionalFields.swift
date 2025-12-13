//
//  OrganizationOptionalFields.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/07/2024.
//

import CoreLocation // for CLLocationCoordinate2D
import SwiftyJSON // for JSON struct

// Set of paraameters (with their defaults) used when creating structs of type Organization.
// Note that Organization is also an entity type in the CoreData database.
public struct OrganizationOptionalFields {
    var organizationWebsite: URL?
    var wikipedia: URL?
    var level2URL: URL?
    var fotobondClubNumber: FotobondClubNumber?
    var contactEmail: String?
    var localizedRemarks: [JSON] // defaults to an empty array instead of to nil

    public init(organizationWebsite: URL? = nil,
                level2URL: URL? = nil,
                wikipedia: URL? = nil,
                fotobondClubNumber: FotobondClubNumber? = nil,
                contactEmail: String? = nil,
                localizedRemarks: [JSON] = []) {
        self.organizationWebsite = organizationWebsite
        self.level2URL = level2URL
        self.wikipedia = wikipedia
        self.fotobondClubNumber = fotobondClubNumber
        self.contactEmail = contactEmail
        self.localizedRemarks = localizedRemarks
    }
}
