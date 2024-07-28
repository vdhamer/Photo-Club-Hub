//
//  MemberOptionalFields.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/07/2024.
//

import Foundation // for URL

// Set of paraameters (with their defaults) used when creating structs of type MemberPortfolio.
// Note that MemberPortfolio is also an entity type in the CoreData database.
struct MemberOptionalFields {
    var memberRolesAndStatus: MemberRolesAndStatus =
        MemberRolesAndStatus(role: [:], status: [:]) // defaults to an empty pair of dictionaries instead of to nil
    var dateInterval: DateInterval?
    var memberWebsite: URL?
    var latestImage: URL?
    var latestThumbnail: URL?
    var level3URL: URL?
}
