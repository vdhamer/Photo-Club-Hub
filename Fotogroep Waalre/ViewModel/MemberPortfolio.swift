//
//  MemberPortfolio.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 03/07/2021.
//

import CoreData // for NSFetchRequest and NSManagedObjectContext
import SwiftUI
import RegexBuilder

extension MemberPortfolio: Comparable {

	public static func < (lhs: MemberPortfolio, rhs: MemberPortfolio) -> Bool {
        if lhs.photographer.fullNameFirstLast != rhs.photographer.fullNameFirstLast {
                return (lhs.photographer.fullNameFirstLast < rhs.photographer.fullNameFirstLast) // main sorting order
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

    var photoClub: PhotoClub {
        if let photoClub = photoClub_ {
            return photoClub
        } else {
            fatalError("Error because photoClub is nil") // something is fundamentally wrong if this happens
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
        return photographer.fullNameFirstLast + " in " + photoClub.fullNameTown
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
        print("member <\(photographer.fullNameLastFirst)> is \(isFormerMember ? "Former " : "")member of \(photoClub.shortName)") // TODO remove comment
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
    static func findCreateUpdate(bgContext: NSManagedObjectContext,
                                 // identifying attributes of a Member:
                                 photoClub: PhotoClub, photographer: Photographer,
                                 // non-identifying attributes of a Member:
                                 memberRolesAndStatus: MemberRolesAndStatus,
                                 dateInterval: DateInterval? = nil,
                                 memberWebsite: URL? = nil,
                                 latestImage: URL? = nil
                                ) -> MemberPortfolio {

        let predicateFormat: String = "photoClub_ = %@ AND photographer_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [photoClub, photographer]
                                   )
        let fetchRequest: NSFetchRequest<MemberPortfolio> = MemberPortfolio.fetchRequest()
        fetchRequest.predicate = predicate
		let memberPortfolios: [MemberPortfolio] = (try? bgContext.fetch(fetchRequest)) ?? [] // nil means absolute failure

        if memberPortfolios.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("Query returned multiple (\(memberPortfolios.count)) memberPortfolios for " +
                              "\(photographer.fullNameFirstLast) in \(photoClub.fullNameTown)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

		if let memberPortfolio = memberPortfolios.first { // already exists, so make sure secondary attributes are up to date
            if update(bgContext: bgContext, memberPortfolio: memberPortfolio,
                      memberRolesAndStatus: memberRolesAndStatus,
                      dateInterval: dateInterval,
                      memberWebsite: memberWebsite,
                      latestImage: latestImage) {
                print("""
                      \(memberPortfolio.photoClub.fullName): \
                      Updated info for member \(memberPortfolio.photographer.fullNameFirstLast)
                      """)
            }
 			return memberPortfolio
		} else {
            let entity = NSEntityDescription.entity(forEntityName: "MemberPortfolio", in: bgContext)!
            let memberPortfolio = MemberPortfolio(entity: entity, insertInto: bgContext) // bg needs special .init()
			memberPortfolio.photoClub_ = photoClub
			memberPortfolio.photographer_ = photographer
            _ = update(bgContext: bgContext, memberPortfolio: memberPortfolio,
                       memberRolesAndStatus: memberRolesAndStatus,
                       dateInterval: dateInterval,
                       memberWebsite: memberWebsite,
                       latestImage: latestImage)
            print("""
                  \(memberPortfolio.photoClub.fullNameTown): \
                  Created new membership for \(memberPortfolio.photographer.fullNameFirstLast)
                  """)
			return memberPortfolio
		}
	}

	// Update non-identifying attributes/properties within existing instance of class MemberPortfolio
    // swiftlint:disable:next function_parameter_count function_body_length
    private static func update(bgContext: NSManagedObjectContext, memberPortfolio: MemberPortfolio,
                               memberRolesAndStatus: MemberRolesAndStatus,
                               dateInterval: DateInterval?,
                               memberWebsite: URL?,
                               latestImage: URL?) -> Bool {
		var needsSaving: Bool = false

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
				try bgContext.save()
                if changed1 { print("""
                                    \(memberPortfolio.photoClub.fullNameTown): \
                                    Changed roles for \(memberPortfolio.photographer.fullNameFirstLast)
                                    """) }
                if changed2 { print("""
                                    \(memberPortfolio.photoClub.fullNameTown): \
                                    Changed start date for \(memberPortfolio.photographer.fullNameFirstLast)
                                    """) }
                if changed3 { print("""
                                    \(memberPortfolio.photoClub.fullNameTown): \
                                    Changed end date for \(memberPortfolio.photographer.fullNameFirstLast)
                                    """) }
                if changed4 { print("""
                                    \(memberPortfolio.photoClub.fullNameTown): \
                                    Changed club website for \(memberPortfolio.photographer.fullNameFirstLast)
                                    """) }
                if changed5 { print("""
                                    \(memberPortfolio.photoClub.fullNameTown): \
                                    Changed latest image for \(memberPortfolio.photographer.fullNameFirstLast) \
                                    to \(latestImage?.lastPathComponent ?? "<noLatestImage>")
                                    """)}
			} catch {
                ifDebugFatalError("Update failed for member \(memberPortfolio.photographer.fullNameFirstLast) " +
                                  "in club \(memberPortfolio.photoClub.fullNameTown): \(error)",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, failure to update this data is only logged. And the app doesn't stop.
			}
		}

        return needsSaving
	}

}

extension MemberPortfolio {

    func refreshFirstImage() {
        let photoClubTown: String = self.photoClub.fullNameTown
        guard photoClubTown == "Fotogroep Waalre (Waalre)" else { return } // code needs closure per photo club

        if let urlIndex = URL(string: self.memberWebsite.absoluteString + "config.xml") { // assume JuiceBox Pro
            ifDebugPrint("\(photoClubTown): starting refreshFirstImage() \(urlIndex.absoluteString) in background")

            // swiftlint:disable:next large_tuple
            var results: (utfContent: Data?, urlResponse: URLResponse?, error: (any Error)?)? = (nil, nil, nil)
            results = URLSession.shared.synchronousDataTask(from: urlIndex)
            guard results != nil && results!.utfContent != nil else {
                print("\(photoClubTown): ERROR - loading refreshFirstImage() \(urlIndex.absoluteString) failed")
                return
            }

            let xmlContent = String(data: results!.utfContent! as Data,
                                    encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            parseXMLContent(xmlContent: xmlContent, member: self)
            ifDebugPrint("\(photoClubTown): completed refreshFirstImage() \(urlIndex.absoluteString)")
        }
    }

    private func parseXMLContent(xmlContent: String, member: MemberPortfolio) { // sample data
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
                  "for \(member.photographer.fullNameFirstLast) in \(member.photoClub.fullName)")
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
