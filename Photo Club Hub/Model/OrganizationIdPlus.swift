//
//  OrganizationIdPlus.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 10/01/2023.
//

import Foundation

public struct OrganizationIdPlus: Sendable { // PhotoClubID plus non-identifying nickname
    var id: OrganizationID
    public var nickname: String

    init(fullName: String, // initializer hides PhotoClubId level
         town: String,
         nickname: String) {
        let id = OrganizationID(fullName: fullName, town: town)
        self.id = id
        self.nickname = nickname
    }

    init(id: OrganizationID, // initializer exposes PhotoClubId level
         nickname: String) {
        self.id = id
        self.nickname = nickname
    }

    // convenience functions
    public var fullName: String { id.fullName }
    public var town: String { id.town }
}

public struct OrganizationID: Hashable, Sendable { // hashable because PhotoClubId is used as dictionary key

    public init(fullName: String, town: String) {
        self.fullName = fullName
        self.town = town
    }

    var fullName: String
    var town: String
}
