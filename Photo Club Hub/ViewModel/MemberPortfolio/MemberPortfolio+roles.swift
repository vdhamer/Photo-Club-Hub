//
//  MemberPortfolio+roles.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 20/10/2023.
//

import Foundation // for Bundle

extension MemberPortfolio { // computed properties related to roles of members in their club

    /// A localized string describing the member's roles and status within the club.
    ///
    /// Builds a natural-language phrase such as `"Member"`, `"Secretary and member"`, or
    /// `"Former treasurer and admin"` by combining any status prefixes (e.g. deceased, former)
    /// with role suffixes (e.g. chairman, secretary) and a trailing membership status word.
    /// Items within each group are joined with the localized word for "and".
    ///
    /// - Parameter languageBundle: The bundle used to resolve all localized strings, allowing the result
    ///   to be rendered in a language other than the system locale.
    /// - Returns: A capitalized, trimmed phrase describing the member's roles and status.
    private func roleDescription(languageBundle: Bundle) -> String {
        var prefixList = [String]()
        var result: String = ""
        let andLocalized = String(localized: "and",
                                  table: "PhotoClubHubData",
                                  bundle: languageBundle,
                                  comment: "To generate strings like \"secretary and admin\"")

        if photographer.isDeceased { // deceased?
            prefixList.append(MemberStatus.deceased.displayNameForHTML(languageBundle: languageBundle))
        }

        if isFormerMember && !isHonoraryMember { // former?
            prefixList.append(MemberStatus.former.displayNameForHTML(languageBundle: languageBundle))
        }

        let suffixList = activeRolesList(languageBundle: languageBundle)
                       + [membershipStatusLabel(languageBundle: languageBundle)]

        for prefix in prefixList {
            result.append(prefix + " ")
        }

        for (index, element) in suffixList.enumerated() {
            result.append(element + " ") // example "secretary "
            if index < suffixList.count-1 {
                result.append(andLocalized + " ") // example "secretary and " unless there are no elements left
            }
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines).capitalizingFirstLetter()
    }

    /// Returns the localized display names of all roles this member currently holds, in declaration order.
    /// - Parameter languageBundle: The bundle used to resolve localized strings.
    private func activeRolesList(languageBundle: Bundle) -> [String] {
        var roles = [String]()

        if isChairman { roles.append(MemberRole.chairman.displayNameForHTML(languageBundle: languageBundle)) }
        if isViceChairman { roles.append(MemberRole.viceChairman.displayNameForHTML(languageBundle: languageBundle)) }
        if isTreasurer { roles.append(MemberRole.treasurer.displayNameForHTML(languageBundle: languageBundle)) }
        if isSecretary { roles.append(MemberRole.secretary.displayNameForHTML(languageBundle: languageBundle)) }
        if isAdmin { roles.append(MemberRole.admin.displayNameForHTML(languageBundle: languageBundle)) }
        if isOther { roles.append(MemberRole.other.displayNameForHTML(languageBundle: languageBundle)) }

        return roles
    }

    /// Returns the single localized word or phrase that describes the member's primary membership status.
    ///
    /// The statuses are mutually exclusive and checked in priority order:
    /// prospective → honorary → coach → current (default).
    /// - Parameter languageBundle: The bundle used to resolve localized strings.
    private func membershipStatusLabel(languageBundle: Bundle) -> String {
        if isProspectiveMember {
            return MemberStatus.prospective.displayNameForHTML(languageBundle: languageBundle)
        }

        if isHonoraryMember {
            return MemberStatus.honorary.displayNameForHTML(languageBundle: languageBundle)
        }

        if isMentor {
            return MemberStatus.coach.displayNameForHTML(languageBundle: languageBundle)
        }

        return MemberStatus.current.displayNameForHTML(languageBundle: languageBundle)
    }

    // Backward-compatible property; uses the system locale via the default module bundle.
    public var roleDescriptionOfClubTown: String { // is or was used in MemberPortfolio, check for dead code later
        roleDescriptionOfClubTown(languageBundle: .photoClubHubDataModule)
    }

    public func roleDescriptionOfClubTown(languageBundle: Bundle) -> String {
        let of2 = String(localized: "of2",
                         table: "PhotoClubHubData",
                         bundle: languageBundle,
                         comment: "<person> of <photo club>")
        return "\(roleDescription(languageBundle: languageBundle)) \(of2) \(self.organization.fullNameTown)"
    }

    public var memberRolesAndStatus: MemberRolesAndStatus {
        get { // conversion from Bool to MemberRolesAndStatus dictionary
            var memberRS = MemberRolesAndStatus(roles: [:], status: [:])

            if photographer.isDeceased { memberRS.status[.deceased] = true }
            if isFormerMember { memberRS.status[.former] = true }
            if isHonoraryMember { memberRS.status[.honorary] = true}
            if isProspectiveMember { memberRS.status[.prospective] = true }
            if isMentor { memberRS.status[.coach] = true }
            if !isFormerMember && !isHonoraryMember && !isProspectiveMember && !isMentor {
                memberRS.status[.current] = true
            }

            if isChairman { memberRS.roles[.chairman] = true }
            if isViceChairman { memberRS.roles[.viceChairman] = true }
            if isTreasurer { memberRS.roles[.treasurer] = true }
            if isSecretary { memberRS.roles[.secretary] = true }
            if isAdmin { memberRS.roles[.admin] = true }
            if isOther { memberRS.roles[.other] = true }

            return memberRS
        }
        set { // merge newValue with existing dictionary
            if let newBool = newValue.status[.deceased] {
                photographer.isDeceased = newBool!
            }
            if let newBool = newValue.status[.former] {
                isFormerMember = newBool!
            }
            if let newBool = newValue.status[.honorary] {
                isHonoraryMember = newBool!
            }
            if let newBool = newValue.status[.prospective] {
                isProspectiveMember = newBool!
            }
            if let newBool = newValue.status[.coach] {
                isMentor = newBool!
            }
            if let newBool = newValue.roles[.chairman] {
                isChairman = newBool!
            }
            if let newBool = newValue.roles[.viceChairman] {
                isViceChairman = newBool!
            }
            if let newBool = newValue.roles[.treasurer] {
                isTreasurer = newBool!
            }
            if let newBool = newValue.roles[.secretary] {
                isSecretary = newBool!
            }
            if let newBool = newValue.roles[.admin] {
                isAdmin = newBool!
            }
            if let newBool = newValue.roles[.other] {
                isOther = newBool!
            }
        }
    }

}
