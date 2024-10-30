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

    fileprivate static let emptyPortfolioURL: String = "http://www.vdHamer.com/fgWaalre/Empty_Website/"

    var membershipStartDate: Date { // non-optional version of membershipStartDate_
        get {
            if membershipStartDate_ == nil {
                return Date.distantPast // membership has no known start date
            } else {
                return membershipStartDate_!
            }
        }
        set { membershipStartDate_ = newValue }
    }

    var membershipEndDate: Date { // non-optional version of membershipEndDate_
        get {
            if membershipEndDate_ == nil {
                return Date.distantFuture
            } else {
                return membershipEndDate_!
            }
        }
        set { membershipEndDate_ = newValue
            if newValue < Date() && !isFormerMember { // no longer a member
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
                level3URL_ = URL(string: MemberPortfolio.emptyPortfolioURL)!
            }
            return level3URL_!
        }
        set {
            level3URL_ = newValue
        }
    }

}
