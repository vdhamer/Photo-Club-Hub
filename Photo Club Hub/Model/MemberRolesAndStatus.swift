//
//  MemberRolesAndStatus.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 14/01/2022.
//

enum MemberRole {
    // a Member can have 0, 1 or more of these MemberRoles at the same time
    case admin // rawValue not used because string needs localization
    case chairman
    case secretary
    case treasurer
    case viceChairman

    func localizedString() -> String {
        switch self {
        case .admin:
            return String(localized: "admin",
                          comment: "Administrative role of member within a club. Used as part of concatenations.")
        case .chairman:
            return String(localized: "chairman",
                          comment: "Administrative role of member within a club. Used as part of concatenations.")
        case .secretary:
            return String(localized: "secretary",
                          comment: "Administrative role of member within a club. Used as part of concatenations.")
        case .treasurer:
            return String(localized: "treasurer",
                          comment: "Administrative role of member within a club. Used as part of concatenations.")
        case .viceChairman:
            return String(localized: "vice-chairman",
                          comment: "Administrative role of member within a club. Used as part of concatenations.")
        }
    }
}

extension MemberRole: CaseIterable, Identifiable {
    var id: String { // switch to self?
        self.localizedString()
    }
}

extension MemberRole: Comparable {
    static func < (lhs: MemberRole, rhs: MemberRole) -> Bool {
        return lhs.localizedString() < rhs.localizedString()
    }
}

enum MemberStatus {
    // a Member can have multiple of these special statusses
    case coach // rawValue not used because string needs localization
    case deceased
    case former
    case honorary
    case current
    case prospective

    func localizedString() -> String {
        switch self {
        case .coach: return String(localized: "external coach",
                                   comment: "Relationship status of member within a club. Used in concatenations.")
        case .deceased: return String(localized: "deceased",
                                   comment: "Relationship status of member within a club. Used as prefix.")
        case .former: return String(localized: "former",
                                   comment: "Relationship status of member within a club. Used as prefex.")
        case .honorary: return String(localized: "honorary member",
                                   comment: "Relationship status of member within a club. Used in concatenations.")
        case .current: return String(localized: "member",
                                   comment: "Default status of member within a club. Used in concatenations.")
        case .prospective: return String(localized: "prospective member",
                                   comment: "Relationship status of member within a club. Used in concatenations.")
        }
    }
}

extension MemberStatus: CaseIterable, Identifiable {
    var id: String {
        self.localizedString()
    }
}

extension MemberStatus: Comparable {
    static func < (lhs: MemberStatus, rhs: MemberStatus) -> Bool {
            return lhs.localizedString() < rhs.localizedString()
    }
}

struct MemberRolesAndStatus: Equatable {
    var role: [MemberRole: Bool?] = [:]
    var status: [MemberStatus: Bool?] = [:]

    func isDeceased() -> Bool? {
        guard let deceased = status[.deceased] else { return nil } // bit problematic type of Bool?? (double optional)
        return deceased
    }
}
