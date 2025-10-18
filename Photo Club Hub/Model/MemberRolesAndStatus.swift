//
//  MemberRolesAndStatus.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 14/01/2022.
//

import SwiftyJSON // for JSON struct
import Foundation // for Bundle

// MARK: - MemberRole

public enum MemberRole {
    // a Member can have 0, 1 or more of these MemberRoles at the same time
    case admin // rawValue not used because string needs localization
    case chairman
    case secretary
    case treasurer
    case viceChairman
    case other

    public func localizedString() -> String {
        let table: String = "PhotoClubHubData"

        switch self {
        case .admin:
            return String(localized: "admin",
                          table: table,
                          bundle: Bundle.photoClubHubDataModule,
                          comment: "Administrative role of member within a club.")
        case .chairman:
            return String(localized: "chairman",
                          table: table,
                          bundle: Bundle.photoClubHubDataModule,
                          comment: "Administrative role of member within a club.")
        case .other:  // used in fgDeGender
            return String(localized: "other",
                          table: table,
                          bundle: Bundle.photoClubHubDataModule,
                          comment: "Administrative role of member within a club.")
        case .secretary:
            return String(localized: "secretary",
                          table: table,
                          bundle: Bundle.photoClubHubDataModule,
                          comment: "Administrative role of member within a club.")
        case .treasurer:
            return String(localized: "treasurer",
                          table: table,
                          bundle: Bundle.photoClubHubDataModule,
                          comment: "Administrative role of member within a club.")
        case .viceChairman: // used in fgWaalre
            return String(localized: "vice-chairman",
                          table: table,
                          bundle: Bundle.photoClubHubDataModule,
                          comment: "Administrative role of member within a club.")
        }
    }
}

extension MemberRole: CaseIterable, Identifiable {
    public var id: String { // switch to self?
        self.localizedString().capitalized
    }
}

extension MemberRole: Comparable {
    public static func < (lhs: MemberRole, rhs: MemberRole) -> Bool {
        return lhs.localizedString() < rhs.localizedString()
    }
}

// MARK: - MemberStatus

public enum MemberStatus {
    // a Member can have multiple of these special statusses
    case coach // rawValue not used because string needs localization
    case deceased // careful: isDeceased belongs to member.photographer.deceased rather than member.isdeceased
    case former
    case honorary
    case current
    case prospective

    func localizedString() -> String {
        let table: String = "PhotoClubHubData"

        switch self {
        case .coach:
            return String(localized: "external coach",
                          table: table, bundle: Bundle.photoClubHubDataModule,
                          comment: "Relationship status of member within a club.")
        case .deceased:
            return String(localized: "deceased",
                          table: table, bundle: Bundle.photoClubHubDataModule,
                          comment: "Relationship status of member within a club. Used as prefix.")
        case .former:
            return String(localized: "former",
                          table: table, bundle: Bundle.photoClubHubDataModule,
                          comment: "Relationship status of member within a club. Used as prefex.")
        case .honorary:
            return String(localized: "honorary member",
                          table: table, bundle: Bundle.photoClubHubDataModule,
                          comment: "Relationship status of member within a club.")
        case .current:
            return String(localized: "member",
                          table: table, bundle: Bundle.photoClubHubDataModule,
                          comment: "Default status of member within a club.")
        case .prospective:
            return String(localized: "prospective member",
                          table: table, bundle: Bundle.photoClubHubDataModule,
                          comment: "Relationship status of member within a club.")
        }
    }
}

extension MemberStatus: CaseIterable, Identifiable {
    public var id: String {
        self.localizedString()
    }
}

extension MemberStatus: Comparable {
    public static func < (lhs: MemberStatus, rhs: MemberStatus) -> Bool {
            return lhs.localizedString() < rhs.localizedString()
    }
}

// Temporary helper function that works both in a standalone app and within the PhotoClubHubData package.
// This can be removed when both Photo Club Hub and Photo Club Hub HTML both use the PhotoClubHubData package.
extension Bundle {
    static var photoClubHubDataModule: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        // Bundle where this source file lives (works for app and framework targets)
        return Bundle(for: _PhotoClubHubDataBundleToken.self)
        #endif
    }
}
private final class _PhotoClubHubDataBundleToken {} // dummy class, only used to determine what current bundle is

// MARK: - MemberRoleAndStatus

public struct MemberRolesAndStatus: Equatable {
    public var roles: [MemberRole: Bool?] = [:]
    public var status: [MemberStatus: Bool?] = [:]

    func isDeceased() -> Bool? {
        guard let deceased = status[.deceased] else { return nil } // bit problematic type of Bool: "double optional"
        return deceased
    }

    public init(roles: [MemberRole: Bool] = [:], status: [MemberStatus: Bool] = [:]) {
        self.roles = roles
        self.status = status
    }

    // swiftlint:disable:next cyclomatic_complexity
    init(jsonRoles: JSON, jsonStatus: JSON) {

        // process content of jsonRoles
        if jsonRoles["isChairman"].exists() {
            roles[.chairman] = jsonRoles["isChairman"].boolValue
        }
        if jsonRoles["isViceChairman"].exists() {
            roles[.viceChairman] = jsonRoles["isViceChairman"].boolValue
        }
        if jsonRoles["isTreasurer"].exists() {
            roles[.treasurer] = jsonRoles["isTreasurer"].boolValue
        }
        if jsonRoles["isSecretary"].exists() {
            roles[.secretary] = jsonRoles["isSecretary"].boolValue
        }
        if jsonRoles["isAdmin"].exists() {
            roles[.admin] = jsonRoles["isAdmin"].boolValue
        }
        if jsonRoles["isOther"].exists() {
            roles[.other] = jsonRoles["isOther"].boolValue
        }

        // process content of jsonStatus
        if jsonStatus["isDeceased"].exists() {
            status[.deceased] = jsonStatus["isDeceased"].boolValue
            if status[.deceased] == true {
                status[.former] = true // Deceased members are considered a strict subset of Former members
            }
        }
        if jsonStatus["isFormerMember"].exists() {
            status[.former] = jsonStatus["isFormerMember"].boolValue
        }
        if jsonStatus["isHonoraryMember"].exists() {
            status[.honorary] = jsonStatus["isHonoraryMember"].boolValue
        }
        if jsonStatus["isMentor"].exists() {
            status[.coach] = jsonStatus["isMentor"].boolValue
        }
        if jsonStatus["isProspectiveMember"].exists() {
            status[.prospective] = jsonStatus["isProspectiveMember"].boolValue
        }

    }
}
