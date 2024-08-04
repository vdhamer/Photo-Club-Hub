//
//  OrganizationIdPlus.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 10/01/2023.
//

import Foundation

struct OrganizationIdPlus: Sendable { // PhotoClubID plus non-identifying nickname
    var id: OrganizationID
    var nickname: String

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
    var fullName: String { id.fullName }
    var town: String { id.town }
}

public struct OrganizationID: Hashable, Sendable { // hashable because PhotoClubId is used as dictionary key
    var fullName: String
    var town: String
}
