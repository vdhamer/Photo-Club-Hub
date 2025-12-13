//
//  MemberOptionalFields.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/07/2024.
//

import Foundation // for URL

// Set of parameters (with their defaults) used when creating structs of type MemberPortfolio.
// Note that MemberPortfolio is also an entity type in the CoreData database.
public struct MemberOptionalFields {
    var featuredImage: URL?
    var featuredImageThumbnail: URL?
    var level3URL: URL?
    var memberRolesAndStatus: MemberRolesAndStatus // defaults to an empty pair of dictionaries instead of to nil
    var fotobondMemberNumber: FotobondMemberNumber? // identification number of members of the Dutch Fotobond
    var membershipStartDate: Date?
    var membershipEndDate: Date?

    public init(featuredImage: URL? = nil,
                featuredImageThumbnail: URL? = nil,
                level3URL: URL? = nil,
                memberRolesAndStatus: MemberRolesAndStatus = MemberRolesAndStatus(roles: [:], status: [:]),
                fotobondMemberNumber: FotobondMemberNumber? = nil,
                membershipStartDate: Date? = nil,
                membershipEndDate: Date? = nil) {
        self.featuredImage = featuredImage
        self.featuredImageThumbnail = featuredImageThumbnail
        self.level3URL = level3URL
        self.memberRolesAndStatus = memberRolesAndStatus
        self.fotobondMemberNumber = fotobondMemberNumber
        self.membershipStartDate = membershipStartDate
        self.membershipEndDate = membershipEndDate
    }
}
