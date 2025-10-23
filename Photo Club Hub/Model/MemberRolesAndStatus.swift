//
//  MemberRolesAndStatus.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 14/01/2022.
//

import SwiftyJSON // for JSON struct
import Foundation // for Bundle

// MARK: - MemberRole

/// A role a club member can hold within their photo club.
///
/// A member can have zero or more roles concurrently.
/// - The enum's `rawValue` serves as a  stable identifier.
/// - Use`displayName` for localized presentation.
public enum MemberRole: String {
    /// Site administrator responsible for managing the club website.
    case admin
    /// Club chairman.
    case chairman
    /// Club secretary.
    case secretary
    /// Club treasurer.
    case treasurer
    /// Vice chairman.
    case viceChairman // Assists the chairman
    /// Other/unspecified role used by some clubs.
    case other
}

extension MemberRole {
    public var displayName: String { // localized
        let localizationTable: String = "PhotoClubHubData"
        let localizationBundle: Bundle = Bundle.photoClubHubDataModule

        switch self {
        case .admin:
            return String(localized: "admin", table: localizationTable, bundle: localizationBundle,
                          comment: "Administrative role of member within a club.")
        case .chairman:
            return String(localized: "chairman", table: localizationTable, bundle: localizationBundle,
                          comment: "Administrative role of member within a club.")
        case .other:  // some clubs like fgDeGender use this
            return String(localized: "other", table: localizationTable, bundle: localizationBundle,
                          comment: "Administrative role of member within a club.")
        case .secretary:
            return String(localized: "secretary", table: localizationTable, bundle: localizationBundle,
                          comment: "Administrative role of member within a club.")
        case .treasurer:
            return String(localized: "treasurer", table: localizationTable, bundle: localizationBundle,
                          comment: "Administrative role of member within a club.")
        case .viceChairman: // some clubs like fgWaalre use this
            return String(localized: "vice-chairman", table: localizationTable, bundle: localizationBundle,
                          comment: "Administrative role of member within a club.")
        }
    }
}

extension MemberRole: CaseIterable, Identifiable, Codable {
    public var id: String { rawValue } // stable, locale-independent identifier
}

extension MemberRole: Comparable {
    public static func < (lhs: MemberRole, rhs: MemberRole) -> Bool {
        return lhs.displayName < rhs.displayName // is sorted based on locale's displayName, not on rawValue
    }
}

// MARK: - MemberStatus

/// The status a club member can hold within their photo club.
///
/// A member can have zero or more statusses concurrently.
/// - The enum's `rawValue` serves as a  stable identifier.
/// - Use`displayName` for localized presentation.
public enum MemberStatus: String {
    /// Photography coaches may guide the club in certain projects
    case coach
    /// Photographer has died. Stored as member.photographer.isDeceased rather than as member.isDeceased.
    case deceased
    /// Ex-member of this club.
    case former
    /// Honorary club member.
    case honorary
    /// Current  club member.
    case current
    /// Aspiring member.
    case prospective
}

extension MemberStatus {
    public var displayName: String {
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

extension MemberStatus: CaseIterable, Identifiable, Codable {
    public var id: String { rawValue } // stable, locale-independent identifier
}

extension MemberStatus: Comparable {
    public static func < (lhs: MemberStatus, rhs: MemberStatus) -> Bool {
            return lhs.displayName < rhs.displayName // is sorted based on locale's displayName, not on rawValue
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
