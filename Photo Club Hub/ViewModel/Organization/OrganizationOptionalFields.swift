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
struct OrganizationOptionalFields {
    var organizationWebsite: URL?
    var wikipedia: URL?
    var fotobondNumber: Int16?
    var coordinates: CLLocationCoordinate2D?
    var localizedRemarks: [JSON] = [] // defaults to an empty array instead of to nil
}
