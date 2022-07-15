//
//  Member.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 03/07/2021.
//

import CoreData // for NSFetchRequest and NSManagedObjectContext
import SwiftUI

extension Member: Comparable {

	public static func < (lhs: Member, rhs: Member) -> Bool {
		return (lhs.photographer.fullName < rhs.photographer.fullName)
	}

}

extension Member { // computed properties (some related to handling optionals)

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
                print("Overruling former membership flag for member \(self.photographer.fullName)")
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

    var photoClub: PhotoClub {
        if let photoClub = photoClub_ {
            return photoClub
        } else {
            fatalError("Error because photoClub is nil")
        }
	}

	var photographer: Photographer {
        if let photographer = photographer_ {
            return photographer
        } else {
            fatalError("Error because photographer is nil")
        }
	}

    public var id: String {
        return photographer.fullName + " in " + photoClub.name
    }

    var memberWebsite: URL {
        get {
            if memberWebsite_ == nil {
                memberWebsite_ = URL(string: "https://www.fotogroepwaalre.nl/fotos/Empty_Website/")!
            }
            return memberWebsite_!
        }
        set {
            memberWebsite_ = newValue
        }
    }

    var roleDescription: String {
        var prefixList = [String]()
        var suffixList = [String]()
        var result: String = ""
        let andLocalized = String(localized: "and", comment: "To generate strings like \"secretary and admin\"")

        if photographer.isDeceased {
            prefixList.append(MemberStatus.deceased.localizedString())
        } else if photographer.isDeviceOwner {
            prefixList.append(MemberStatus.deviceOwner.localizedString() +
                              " " + andLocalized)
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
            result.append(element + " ")
            if index < suffixList.count-1 {
                result.append(andLocalized + " ")
            }
        }
        return result.trimmingCharacters(in: .whitespacesAndNewlines).capitalizingFirstLetter()
    }

    var memberRolesAndStatus: MemberRolesAndStatus {
        get { // conversion from Bool to dictionary
            var memberRS = MemberRolesAndStatus(role: [:], stat: [:])

            if photographer.isDeceased { memberRS.stat[.deceased] = true }
            if photographer.isDeviceOwner { memberRS.stat[.deviceOwner] = true }
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
            if let newBool = newValue.stat[.deviceOwner] {
                photographer.isDeviceOwner = newBool!
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

extension Member { // findCreateUpdate() records in Member table

	// Find existing object or create a new object
	// Update existing attributes or fill the new object
    static func findCreateUpdate(context: NSManagedObjectContext,
                                 // identifying attributes of a Member
                                 photoClub: PhotoClub, photographer: Photographer,
                                 // other attributes of a Member
                                 memberRolesAndStatus: MemberRolesAndStatus,
                                 dateInterval: DateInterval? = nil,
                                 memberWebsite: URL? = nil
                                ) -> Member {
        let predicateFormat: String = "photoClub_ = %@ AND photographer_ = %@" // avoid localization
        let request = fetchRequest(predicate: NSPredicate(format: predicateFormat, photoClub, photographer))

		let members: [Member] = (try? context.fetch(request)) ?? [] // nil means absolute failure

		if let member = members.first { // already exists, so make sure secondary attributes are up to date
            if update(context: context, member: member,
                      memberRolesAndStatus: memberRolesAndStatus,
                      dateInterval: dateInterval,
                      memberWebsite: memberWebsite) {
                print("Updated info for member \(member.photographer.fullName) in club \(member.photoClub.name)")
            }
 			return member
		} else {
			let member = Member(context: context) // create new Member object
			member.photoClub_ = photoClub
			member.photographer_ = photographer
            _ = update(context: context, member: member,
                       memberRolesAndStatus: memberRolesAndStatus,
                       dateInterval: dateInterval,
                       memberWebsite: memberWebsite)
            print("Created new membership for \(member.photographer.fullName) in \(member.photoClub.name)")
			return member
		}
	}

	// Update non-identifying attributes/properties within existing instance of class PhotoClub
    private static func update(context: NSManagedObjectContext, member: Member,
                               memberRolesAndStatus: MemberRolesAndStatus,
                               dateInterval: DateInterval?,
                               memberWebsite: URL?) -> Bool {
		var modified: Bool = false

        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump // not sure about this, prevents error

        // function only works for non-optional Types.
        // If optional support needed, create variant with "inout Type?" instead of "inout Type"
        func updateIfChanged<Type>(update persistedValue: inout Type, with newValue: Type?) where Type: Equatable {
            if let newValue = newValue {
                if newValue != persistedValue {
                    persistedValue = newValue
                    modified = true
                }
            }
        }

        let oldMemberRolesAndStatus = member.memberRolesAndStatus // copy of original value
        member.memberRolesAndStatus = memberRolesAndStatus // actually this setter does merging (overload + or += ?)
        let newMemberRolesAndStatus = member.memberRolesAndStatus // copy after possible changes
        modified = (oldMemberRolesAndStatus != newMemberRolesAndStatus)

        updateIfChanged(update: &member.dateIntervalStart, with: dateInterval?.start)
        updateIfChanged(update: &member.dateIntervalEnd, with: dateInterval?.end)
        updateIfChanged(update: &member.memberWebsite, with: memberWebsite)

		if modified {
			do {
				try context.save()
			} catch {
                fatalError("Update failed for member \(member.photographer.fullName) in club \(member.photoClub.name)" +
                           "\(error)")
			}
		}
        return modified
	}

}

extension Member { // convenience function

	static func fetchRequest(predicate: NSPredicate) -> NSFetchRequest<Member> { // pre-iOS 15 version
		let request = NSFetchRequest<Member>(entityName: "Member")

		request.predicate = predicate // WHERE part of the SQL query
        request.sortDescriptors = [
                                    NSSortDescriptor(keyPath: \Member.photographer_?.givenName_, ascending: true),
									NSSortDescriptor(keyPath: \Member.photographer_?.familyName_, ascending: true),
                                    NSSortDescriptor(keyPath: \Member.photoClub_?.name_, ascending: true)
		]
		return request
	}

}
