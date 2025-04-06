//
//  MemberPortfolio.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 03/07/2021.
//

import Foundation // for Date, URL, etc.

extension MemberPortfolio: Comparable {

	public static func < (lhs: MemberPortfolio, rhs: MemberPortfolio) -> Bool {
        if lhs.photographer.fullNameFirstLast != rhs.photographer.fullNameFirstLast {
                return (lhs.photographer.fullNameFirstLast < rhs.photographer.fullNameFirstLast) // main sorting order
        } else {
            return (lhs.organization.fullName < rhs.organization.fullName) // secondary sorting criterium
        }
	}

}

extension MemberPortfolio { // expose computed properties (some related to handling optionals)

    static let emptyPortfolioURL: String = "http://www.vdHamer.com/fgWaalre/Empty_Website/"

    var membershipStartDate: Date? {
        get { return membershipStartDate_ }
        set { membershipStartDate_ = newValue }
    }

    var membershipEndDate: Date? { // nil means photographer is still a club member
        get { return membershipEndDate_ }
        set {
            membershipEndDate_ = newValue
            if newValue != nil, newValue! < Date() && isFormerMember == false { // no longer a member
                isFormerMember = true
                ifDebugFatalError("Overruling former membership flag for member \(self.photographer.fullNameFirstLast)")
            }
        }
    }

    var organization: Organization {
        if let organization = organization_ {
            return organization
        } else {
            fatalError("Error because organization is nil") // something is fundamentally wrong if this happens
        }
	}

	var photographer: Photographer {
        if let photographer = photographer_ {
            return photographer
        } else {
            fatalError("Error because photographer is nil") // something is fundamentally wrong if this happens
        }
	}

    var level3URL: URL {
        get {
            if level3URL_ == nil {
                let string = MemberPortfolio.emptyPortfolioURL
                level3URL_ = URL(string: string)!
            }
            return level3URL_!
        }
        set {
            level3URL_ = newValue
        }
    }

}
