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

	var dateIntervalEnd: Date { // non-optional version of toDT_
		get {
			if let dateIntervalEnd = dateIntervalEnd_ {
				return dateIntervalEnd
			} else { // membership has no known termination date
				return Date.distantFuture
			}
		}
		set { dateIntervalEnd_ = newValue
            if newValue < Date() && !isFormerMember { // no longer a member
                isFormerMember = true
                print("Overruling former membership flag for member \(self.photographer.fullNameFirstLast)")
            }
        }
	}

    var dateIntervalStart: Date { // non-optional version of fromDT_
        get {
            if let dateIntervalStart = dateIntervalStart_ {
                return dateIntervalStart
            } else { // membership has no known start date
                return Date.distantPast
            }
        }
        set { dateIntervalStart_ = newValue }
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

    public var id: String {
        return photographer.fullNameFirstLast + " in " + organization.fullNameTown
    }

    var level3URL: URL {
        get {
            if level3URL_ == nil {
                level3URL_ = URL(string: "https://www.fotogroepwaalre.nl/fotos/Empty_Website/")!
            }
            return level3URL_!
        }
        set {
            level3URL_ = newValue
        }
    }

}
