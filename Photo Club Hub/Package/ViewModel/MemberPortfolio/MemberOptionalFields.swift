//
//  MemberOptionalFields.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/07/2024.
//

import Foundation // for URL

// Set of parameters (with their defaults) used when creating structs of type MemberPortfolio.
// Note that MemberPortfolio is also an entity type in the CoreData database.
struct MemberOptionalFields {
    var featuredImage: URL?
    var featuredImageThumbnail: URL?
    var level3URL: URL?
    var memberRolesAndStatus: MemberRolesAndStatus =
        MemberRolesAndStatus(roles: [:], status: [:]) // defaults to an empty pair of dictionaries instead of to nil
    var fotobondNumber: Int32? // identification number of members of the Dutch Fotobond
    var membershipStartDate: Date?
    var membershipEndDate: Date?
}
