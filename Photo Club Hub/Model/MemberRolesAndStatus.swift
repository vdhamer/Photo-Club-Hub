//
//  MemberRolesAndStatus.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 14/01/2022.
//

import SwiftyJSON // for JSON struct
import Foundation // for Bundle

// MARK: - MemberRole

/// A role a club member can hold within a photo club.
///
/// A member can have zero or more roles within one club simultaneously (e.g. Vice-chairman and Admin).
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

/// Localized display names for `MemberRole`.
///
/// Two variants are provided so a role can be rendered either in the system locale
/// (for normal app UI) or in a caller-supplied bundle (for generating multilingual HTML
/// pages, where each page needs its own language regardless of the system locale).
extension MemberRole {
    /// The role's localized display name in the system locale. Set using e.g. Settings or `Edit Scheme...`.
    ///
    /// Resolves strings against the `PhotoClubHubData` table in the package's own
    /// resource bundle. Use this for in-app UI; use `displayName(bundle:)` when generating
    /// content for a specific target language.
    public var displayNameForAppUI: String { displayNameForHTML(languageBundle: .photoClubHubDataModule) }

    /// The role's localized display name in the language of the supplied bundle.
    ///
    /// Pass a language-specific `.lproj` sub-bundle (typically obtained via
    /// `Bundle.photoClubHubDataModuleForLanguage(_:)`) to render the role in a chosen
    /// language rather than the system locale.
    /// - Parameter bundle: The bundle to resolve `PhotoClubHubData` strings against.
    /// - Returns: The role's localized display name.
    public func displayNameForHTML(languageBundle: Bundle) -> String {
        switch self {
        case .admin:
            return String(localized: "admin",
                          table: "PhotoClubHubData",
                          bundle: languageBundle,
                          comment: "Administrative role of member within a club.")
        case .chairman:
            return String(localized: "chairman",
                          table: "PhotoClubHubData",
                          bundle: languageBundle,
                          comment: "Administrative role of member within a club.")
        case .other:  // some clubs like fgDeGender use this
            return String(localized: "other",
                          table: "PhotoClubHubData",
                          bundle: languageBundle,
                          comment: "Administrative role of member within a club.")
        case .secretary:
            return String(localized: "secretary",
                          table: "PhotoClubHubData",
                          bundle: languageBundle,
                          comment: "Administrative role of member within a club.")
        case .treasurer:
            return String(localized: "treasurer",
                          table: "PhotoClubHubData",
                          bundle: languageBundle,
                          comment: "Administrative role of member within a club.")
        case .viceChairman: // some clubs like fgWaalre use this
            return String(localized: "vice-chairman",
                          table: "PhotoClubHubData",
                          bundle: languageBundle,
                          comment: "Administrative role of member within a club.")
        }
    }
}

/// Standard collection / identity / serialization conformances for `MemberRole`.
///
/// - `CaseIterable` lets UI code (e.g. pickers) iterate all defined roles.
/// - `Identifiable` lets `MemberRole` be used directly in SwiftUI lists and `ForEach`.
/// - `Codable` enables JSON round-tripping through the enum's `rawValue`.
extension MemberRole: CaseIterable, Identifiable, Codable {
    /// Stable, locale-independent identifier using the enum's `rawValue`.
    ///
    /// Safe to persist or send over the wire: it does not change when the user's
    /// locale changes, unlike `displayNameForAppUI`.
    public var id: String { rawValue }
}

/// Ordering for `MemberRole`, used (in iOS app) when rendering sorted lists of roles.
///
/// Roles are compared by their localized `displayNameForAppUI` rather than by `rawValue`,
/// so a sorted list reads naturally in the user's current language. Note that this
/// means the sort order is locale-dependent and not stable across languages.
extension MemberRole: Comparable {
    public static func < (lhs: MemberRole, rhs: MemberRole) -> Bool {
        return lhs.displayNameForAppUI < rhs.displayNameForAppUI
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

/// Localized display names for `MemberStatus`.
///
/// Two variants are provided so a status can be rendered either in the system locale
/// (for normal app UI) or in a caller-supplied bundle (for generating multilingual HTML
/// pages, where each page needs its own language regardless of the system locale).
extension MemberStatus {
    /// The status's localized display name in the system locale. Set using e.g. Settings or `Edit Scheme...`.
    ///
    /// Resolves strings against the `PhotoClubHubData` table in the package's own resource bundle.
    /// Use this for in-app UI.
    /// Use `displayNameForHTML(languageBundle:)` when generating content for a specific target language.
    public var displayNameForAppUI: String { displayNameForHTML(languageBundle: .photoClubHubDataModule) }

    /// The status's localized display name in the language of the supplied bundle.
    ///
    /// Pass a language-specific `.lproj` sub-bundle (typically obtained via
    /// `Bundle.photoClubHubDataModuleForLanguage(_:)`) to render the status in a chosen
    /// language rather than the system locale.
    /// - Parameter languageBundle: The bundle to resolve `PhotoClubHubData` strings against.
    /// - Returns: The status's localized display name.
    public func displayNameForHTML(languageBundle: Bundle) -> String {
        switch self {
        case .coach:
            return String(localized: "external coach",
                          table: "PhotoClubHubData",
                          bundle: languageBundle,
                          comment: "Relationship status of member within a club.")
        case .deceased:
            return String(localized: "deceased",
                          table: "PhotoClubHubData",
                          bundle: languageBundle,
                          comment: "Relationship status of member within a club. Used as prefix.")
        case .former:
            return String(localized: "former",
                          table: "PhotoClubHubData",
                          bundle: languageBundle,
                          comment: "Relationship status of member within a club. Used as prefex.")
        case .honorary:
            return String(localized: "honorary member",
                          table: "PhotoClubHubData",
                          bundle: languageBundle,
                          comment: "Relationship status of member within a club.")
        case .current:
            return String(localized: "member",
                          table: "PhotoClubHubData",
                          bundle: languageBundle,
                          comment: "Default status of member within a club.")
        case .prospective:
            return String(localized: "prospective member",
                          table: "PhotoClubHubData",
                          bundle: languageBundle,
                          comment: "Relationship status of member within a club.")
        }
    }
}

/// Standard collection / identity / serialization conformances for `MemberStatus`.
///
/// - `CaseIterable` lets UI code (e.g. pickers) iterate all defined statuses.
/// - `Identifiable` lets `MemberStatus` be used directly in SwiftUI lists and `ForEach`.
/// - `Codable` enables JSON round-tripping through the enum's `rawValue`.
extension MemberStatus: CaseIterable, Identifiable, Codable {
    /// Stable, locale-independent identifier using the enum's `rawValue`.
    ///
    /// Safe to persist or send over the wire: it does not change when the user's
    /// locale changes, unlike `displayNameForAppUI`.
    public var id: String { rawValue }
}

/// Ordering for `MemberStatus`, used (in iOS app) when rendering sorted lists of statuses.
///
/// Statuses are compared by their localized `displayNameForAppUI` rather than by `rawValue`,
/// so a sorted list reads naturally in the user's current language. Note that this
/// means the sort order is locale-dependent and not stable across languages.
extension MemberStatus: Comparable {
    public static func < (lhs: MemberStatus, rhs: MemberStatus) -> Bool {
        return lhs.displayNameForAppUI < rhs.displayNameForAppUI
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

    /// Returns the language-specific sub-bundle of the PhotoClubHubData module bundle.
    ///
    /// Use this when generating multilingual HTML pages so that strings from the `PhotoClubHubData`
    /// table (e.g. member status/role display names) are resolved in the target language rather than
    /// the system locale. Falls back to `photoClubHubDataModule` if no matching `.lproj` is found.
    public static func photoClubHubDataModuleForLanguage(_ languageID: String) -> Bundle {
        if let path = Bundle.photoClubHubDataModule.path(forResource: languageID, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return Bundle.photoClubHubDataModule
    }
}

private final class _PhotoClubHubDataBundleToken {} // used only to determine what the current bundle is

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
