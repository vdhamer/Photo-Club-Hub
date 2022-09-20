//
//  MemberPortfolio.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 03/07/2021.
//

import CoreData // for NSFetchRequest and NSManagedObjectContext
import SwiftUI

extension MemberPortfolio: Comparable {

	public static func < (lhs: MemberPortfolio, rhs: MemberPortfolio) -> Bool {
		return (lhs.photographer.fullName < rhs.photographer.fullName)
	}

}

extension MemberPortfolio { // computed properties (some related to handling optionals)

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

    var latestImage: URL {
        get {
            if latestImage_ == nil {
                let urlTestStrings: [String] = [
                    "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/07/2022_Textielmuseum_025.jpg",
                    "https://www.fotogroepwaalre.nl/wp-content/uploads/2022/07/2022_FotogroepWaalre_050.jpg",
                    "https://www.fotogroepwaalre.nl/wp-content/uploads/2021/09/2021_FotogroepWaalre_067.jpg",
                    "https://www.fotogroepwaalre.nl/wp-content/uploads/2021/09/2021_FotogroepWaalre_064.jpg",
                    "https://www.fotogroepwaalre.nl/wp-content/uploads/2020/11/2020_FotogroepWaalre_018.jpg",
                    "https://www.fotogroepwaalre.nl/wp-content/uploads/2020/11/2020_FotogroepWaalre_027.jpg"
                ]
                latestImage_ = URL(string: urlTestStrings[Int.random(in: 0..<urlTestStrings.count)])!
            }
            return latestImage_!
        }
        set {
            latestImage_ = newValue
        }
    }

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

extension MemberPortfolio { // findCreateUpdate() records in Member table

	// Find existing object or create a new object
	// Update existing attributes or fill the new object
    static func findCreateUpdate(context: NSManagedObjectContext,
                                 // identifying attributes of a Member
                                 photoClub: PhotoClub, photographer: Photographer,
                                 // other attributes of a Member
                                 memberRolesAndStatus: MemberRolesAndStatus,
                                 dateInterval: DateInterval? = nil,
                                 memberWebsite: URL? = nil
                                ) -> MemberPortfolio {
        let predicateFormat: String = "photoClub_ = %@ AND photographer_ = %@" // avoid localization
        let request = fetchRequest(predicate: NSPredicate(format: predicateFormat, photoClub, photographer))

		let memberPortfolios: [MemberPortfolio] = (try? context.fetch(request)) ?? [] // nil means absolute failure

		if let memberPortfolio = memberPortfolios.first { // already exists, so make sure secondary attributes are up to date
            if update(context: context, memberPortfolio: memberPortfolio,
                      memberRolesAndStatus: memberRolesAndStatus,
                      dateInterval: dateInterval,
                      memberWebsite: memberWebsite) {
                print("Updated info for member \(memberPortfolio.photographer.fullName) " +
                      "in club \(memberPortfolio.photoClub.name)")
            }
 			return memberPortfolio
		} else {
			let memberPortfolio = MemberPortfolio(context: context) // create new Member object
			memberPortfolio.photoClub_ = photoClub
			memberPortfolio.photographer_ = photographer
            _ = update(context: context, memberPortfolio: memberPortfolio,
                       memberRolesAndStatus: memberRolesAndStatus,
                       dateInterval: dateInterval,
                       memberWebsite: memberWebsite)
            print("Created new membership for \(memberPortfolio.photographer.fullName) " +
                  "in \(memberPortfolio.photoClub.name)")
			return memberPortfolio
		}
	}

	// Update non-identifying attributes/properties within existing instance of class PhotoClub
    private static func update(context: NSManagedObjectContext, memberPortfolio: MemberPortfolio,
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

        let oldMemberRolesAndStatus = memberPortfolio.memberRolesAndStatus // copy of original value
        // actually this setter does merging (overload + or += operators for this?)
        memberPortfolio.memberRolesAndStatus = memberRolesAndStatus
        let newMemberRolesAndStatus = memberPortfolio.memberRolesAndStatus // copy after possible changes
        modified = (oldMemberRolesAndStatus != newMemberRolesAndStatus)

        updateIfChanged(update: &memberPortfolio.dateIntervalStart, with: dateInterval?.start)
        updateIfChanged(update: &memberPortfolio.dateIntervalEnd, with: dateInterval?.end)
        updateIfChanged(update: &memberPortfolio.memberWebsite, with: memberWebsite)

		if modified {
			do {
				try context.save()
			} catch {
                fatalError("Update failed for member \(memberPortfolio.photographer.fullName) " +
                           "in club \(memberPortfolio.photoClub.name): \(error)")
			}
		}
        return modified
	}

}

extension MemberPortfolio { // convenience function

	static func fetchRequest(predicate: NSPredicate) -> NSFetchRequest<MemberPortfolio> { // pre-iOS 15 version
		let request = NSFetchRequest<MemberPortfolio>(entityName: "MemberPortfolio")

		request.predicate = predicate // WHERE part of the SQL query
        request.sortDescriptors =
            [
                NSSortDescriptor(keyPath: \MemberPortfolio.photographer_?.givenName_, ascending: true),
                NSSortDescriptor(keyPath: \MemberPortfolio.photographer_?.familyName_, ascending: true),
                NSSortDescriptor(keyPath: \MemberPortfolio.photoClub_?.name_, ascending: true)
            ]
		return request
	}

}
