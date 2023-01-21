//
//  MemberPortfolio.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 03/07/2021.
//

import CoreData // for NSFetchRequest and NSManagedObjectContext
import SwiftUI
import RegexBuilder

extension MemberPortfolio: Comparable {

	public static func < (lhs: MemberPortfolio, rhs: MemberPortfolio) -> Bool {
        if lhs.photographer.fullName != rhs.photographer.fullName {
                return (lhs.photographer.fullName < rhs.photographer.fullName) // primary sorting criterium
        } else {
            return (lhs.photoClub.fullName < rhs.photoClub.fullName) // secondary sorting criterium
        }
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
        return photographer.fullName + " in " + photoClub.fullNameCommaTown
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
                                 memberWebsite: URL? = nil,
                                 latestImage: URL? = nil
                                ) -> MemberPortfolio {
        let predicateFormat: String = "photoClub_ = %@ AND photographer_ = %@" // avoid localization
        let request = fetchRequest(predicate: NSPredicate(format: predicateFormat, photoClub, photographer))

		let memberPortfolios: [MemberPortfolio] = (try? context.fetch(request)) ?? [] // nil means absolute failure

		if let memberPortfolio = memberPortfolios.first { // already exists, so make sure secondary attributes are up to date
            if update(context: context, memberPortfolio: memberPortfolio,
                      memberRolesAndStatus: memberRolesAndStatus,
                      dateInterval: dateInterval,
                      memberWebsite: memberWebsite,
                      latestImage: latestImage) {
                print("Updated info for member \(memberPortfolio.photographer.fullName) " +
                      "in club \(memberPortfolio.photoClub.fullName)")
            }
 			return memberPortfolio
		} else {
			let memberPortfolio = MemberPortfolio(context: context) // create new Member object
			memberPortfolio.photoClub_ = photoClub
			memberPortfolio.photographer_ = photographer
            _ = update(context: context, memberPortfolio: memberPortfolio,
                       memberRolesAndStatus: memberRolesAndStatus,
                       dateInterval: dateInterval,
                       memberWebsite: memberWebsite,
                       latestImage: latestImage)
            print("Created new membership for \(memberPortfolio.photographer.fullName) " +
                  "in \(memberPortfolio.photoClub.fullName) of \(memberPortfolio.photoClub.town)")
			return memberPortfolio
		}
	}

	// Update non-identifying attributes/properties within existing instance of class MemberPortfolio
    // swiftlint:disable:next function_parameter_count
    private static func update(context: NSManagedObjectContext, memberPortfolio: MemberPortfolio,
                               memberRolesAndStatus: MemberRolesAndStatus,
                               dateInterval: DateInterval?,
                               memberWebsite: URL?,
                               latestImage: URL?) -> Bool {
		var needsSaving: Bool = false

        context.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump // not sure about this, prevents error

        // function only works for non-optional Types.
        // If optional support needed, create variant with "inout Type?" instead of "inout Type"
        func updateIfChanged<Type>(update persistedValue: inout Type,
                                   with newValue: Type?) -> Bool // true only if needsSaving
                                   where Type: Equatable {
            if let newValue { // nil means no new value known - and thus doesn't erase existing value
                if persistedValue != newValue {
                    persistedValue = newValue // actual update
                    return true // update needs to be saved
                }
            }
            return false
        }

        func updateIfChangedOptional<Type>(update persistedValue: inout Type?,
                                           with newValue: Type?) -> Bool // true only if needsSaving
                                           where Type?: Equatable {
            if let newValue { // nil means no new value known - and thus doesn't erase existing value
                if persistedValue != newValue {
                    persistedValue = newValue // actual update
                    return true // update needs to be saved
                }
            }
            return false
        }

        let oldMemberRolesAndStatus = memberPortfolio.memberRolesAndStatus // copy of original value
        // actually this setter does merging (overload + or += operators for this?)
        memberPortfolio.memberRolesAndStatus = memberRolesAndStatus
        let newMemberRolesAndStatus = memberPortfolio.memberRolesAndStatus // copy after possible changes

        let changed1 = oldMemberRolesAndStatus != newMemberRolesAndStatus
        let changed2 = updateIfChanged(update: &memberPortfolio.dateIntervalStart, with: dateInterval?.start)
        let changed3 = updateIfChanged(update: &memberPortfolio.dateIntervalEnd, with: dateInterval?.end)
        let changed4 = updateIfChanged(update: &memberPortfolio.memberWebsite, with: memberWebsite)
        let changed5 = updateIfChangedOptional(update: &memberPortfolio.latestImageURL, with: latestImage)
        needsSaving = changed1 || changed2 || changed3 || changed4 || changed5 // forces execution of updateIfChanged()

		if needsSaving {
			do {
				try context.save()
                if changed1 { print("Changed roles for \(memberPortfolio.photographer.fullName)") }
                if changed2 { print("Changed start date for \(memberPortfolio.photographer.fullName)") }
                if changed3 { print("Changed end date for \(memberPortfolio.photographer.fullName)") }
                if changed4 { print("Changed club website for \(memberPortfolio.photographer.fullName)") }
                if changed5 { print("Changed latest image for \(memberPortfolio.photographer.fullName) " +
                                    "to \(String(describing: latestImage?.absoluteString))")
                }
			} catch {
                fatalError("Update failed for member \(memberPortfolio.photographer.fullName) " +
                           "in club \(memberPortfolio.photoClub.fullName): \(error)")
			}
		}

        return needsSaving
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
                NSSortDescriptor(keyPath: \MemberPortfolio.photoClub_?.name_, ascending: true),
                NSSortDescriptor(keyPath: \MemberPortfolio.photoClub_?.town_, ascending: true)
            ]
		return request
	}

}

extension MemberPortfolio {

    func refreshFirstImage() async {
        let photoClub: String = self.photoClub.fullName
        guard photoClub == "Fotogroep Waalre" else { return } // code needs closure per photo club (see issue)

        if let urlIndex = URL(string: self.memberWebsite.absoluteString + "config.xml") { // assume JuiceBox Pro
            print("\(photoClub): starting refreshFirstImage() \(urlIndex.absoluteString) in background")

            var results: (utfContent: Data?, urlResponse: URLResponse?)? = (nil, nil)
            results = try? await URLSession.shared.data(from: urlIndex)
            guard results != nil && results!.utfContent != nil else {
                print("\(photoClub): ERROR - loading refreshFirstImage() \(urlIndex.absoluteString) failed")
                return
            }

            let xmlContent = String(data: results!.utfContent! as Data,
                                    encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            parseXMLContent(xmlContent: xmlContent, member: self)
            print("\(photoClub): completed refreshFirstImage() \(urlIndex.absoluteString)")
        }
    }

    private func parseXMLContent(xmlContent: String, member: MemberPortfolio) {
        //    <?xml version="1.0" encoding="UTF-8"?>
        //    <juiceboxgallery
        //                 galleryTitlePosition="NONE"
        //                     showOverlayOnLoad="false"
        //                     :
        //                     imageTransitionType="CROSS_FADE"
        //         >
        //             <image imageURL="images/image1.jpg" thumbURL="thumbs/image1.jpg" linkURL="" linkTarget="_blank">
        //             <title><![CDATA[]]></title>
        //             <caption><![CDATA[2022]]></caption>
        //         </image>
        //             <image imageURL="images/image2.jpg" thumbURL="thumbs/image2.jpg" linkURL="" linkTarget="_blank">
        //             <title><![CDATA[]]></title>
        //             <caption><![CDATA[2022]]></caption>
        //     </juiceboxgallery>

        let regex = Regex {
            "<image imageURL=\""
            Capture {
                "images/"
                OneOrMore(.any, .reluctant)
            }
            "\"" // closing double quote
            OneOrMore(.horizontalWhitespace)
            "thumbURL=\""
            Capture {
                "thumbs/"
                OneOrMore(.any, .reluctant)
            }
            "\"" // closing double quote
        }

        guard let match = try? regex.firstMatch(in: xmlContent) else {
            print("\(photoClub.fullName): ERROR - could not find image in parseXMLContent() " +
                  "for \(member.photographer.fullName) in \(member.photoClub.fullName)")
            return
        }
        let (_, _, thumbSuffix) = match.output
        let thumbURL = URL(string: self.memberWebsite.absoluteString + thumbSuffix)

        if member.latestImageURL != thumbURL && thumbURL != nil {
            member.latestImageURL = thumbURL // this is where it happens. Note that there is context.save()
            print("\(photoClub.fullName): found new thumbnail \(thumbURL!)")
        }
    }

}
