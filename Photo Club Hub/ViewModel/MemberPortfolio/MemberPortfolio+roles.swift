//
//  MemberPortfolio+roles.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 20/10/2023.
//

extension MemberPortfolio { // computed properties related to roles of members in their club

    var roleDescription: String {
        var prefixList = [String]()
        var suffixList = [String]()
        var result: String = ""
        let andLocalized = String(localized: "and", comment: "To generate strings like \"secretary and admin\"")

        if photographer.isDeceased {
            prefixList.append(MemberStatus.deceased.localizedString())
        }
        if isFormerMember && !isHonoraryMember { prefixList.append(MemberStatus.former.localizedString()) }

        if isChairman { suffixList.append(MemberRole.chairman.localizedString()) }
        if isViceChairman { suffixList.append(MemberRole.viceChairman.localizedString()) }
        if isTreasurer { suffixList.append(MemberRole.treasurer.localizedString()) }
        if isSecretary { suffixList.append(MemberRole.secretary.localizedString()) }
        if isAdmin { suffixList.append(MemberRole.admin.localizedString()) }

        if isProspectiveMember { suffixList.append(MemberStatus.prospective.localizedString()) } else {
            if isHonoraryMember { suffixList.append(MemberStatus.honorary.localizedString()) } else {
                if isMentor { suffixList.append(MemberStatus.coach.localizedString()) } else {
                    suffixList.append(MemberStatus.current.localizedString())
                }
            }
        }

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

    var roleDescriptionOfClubTown: String {
        let of2 = String(localized: "of2", comment: "<person> of <photo club>")
        return "\(roleDescription) \(of2) \(self.organization.fullNameTown)"
    }

    var memberRolesAndStatus: MemberRolesAndStatus {
        get { // conversion from Bool to dictionary
            var memberRS = MemberRolesAndStatus(role: [:], stat: [:])

            if photographer.isDeceased { memberRS.stat[.deceased] = true }
            if isFormerMember { memberRS.stat[.former] = true }
            if isHonoraryMember { memberRS.stat[.honorary] = true}
            if isProspectiveMember { memberRS.stat[.prospective] = true }
            if isMentor { memberRS.stat[.coach] = true }
            if !isFormerMember && !isHonoraryMember && !isProspectiveMember && !isMentor {
                memberRS.stat[.current] = true
            }

            if isChairman { memberRS.role[.chairman] = true }
            if isViceChairman { memberRS.role[.viceChairman] = true }
            if isTreasurer { memberRS.role[.treasurer] = true }
            if isSecretary { memberRS.role[.secretary] = true }
            if isAdmin { memberRS.role[.admin] = true }

            return memberRS
        }
        set { // merge newValue with existing dictionary
            if let newBool = newValue.stat[.deceased] {
                photographer.isDeceased = newBool!
            }
            if let newBool = newValue.stat[.former] {
                isFormerMember = newBool!
            }
            if let newBool = newValue.stat[.honorary] {
                isHonoraryMember = newBool!
            }
            if let newBool = newValue.stat[.prospective] {
                isProspectiveMember = newBool!
            }
            if let newBool = newValue.stat[.coach] {
                isMentor = newBool!
            }
            if let newBool = newValue.role[.chairman] {
                isChairman = newBool!
            }
            if let newBool = newValue.role[.viceChairman] {
                isViceChairman = newBool!
            }
            if let newBool = newValue.role[.treasurer] {
                isTreasurer = newBool!
            }
            if let newBool = newValue.role[.secretary] {
                isSecretary = newBool!
            }
            if let newBool = newValue.role[.admin] {
                isAdmin = newBool!
            }
        }
    }

}
