//
//  PhotoClub.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 03/07/2021.
//

import CoreData // needed for NSSet
import CoreLocation // needed for coordinate translation
import SwiftUI // for UserInterfaceSizeClass
// import SwiftyJSON // for JSON type

extension Organization: Comparable {

	public static func < (lhs: Organization, rhs: Organization) -> Bool {
		return lhs.fullName < rhs.fullName
	}

}

extension Organization {

    // MARK: - getters and setters

	var members: Set<MemberPortfolio> {
		get { (members_ as? Set<MemberPortfolio>) ?? [] }
		set { members_ = newValue as NSSet }
	}

    static var hackOrganizationTypeEnum: OrganizationTypeEnum = OrganizationTypeEnum.club

    var organizationType: OrganizationType {
        get { // careful: cannot read organizationType on background thread if database still contains nil
            let organizationType: OrganizationType
            var hack = false

            if organizationType_ != nil {
                organizationType = organizationType_! // not nil, should be the case
            } else if Thread.isMainThread { // frantic hack to avoid fatal error
                let persistenceController = PersistenceController.shared // for Core Data
                let viewContext = persistenceController.container.viewContext
                let orgTypeObjectID: NSManagedObjectID =
                    OrganizationType.enum2objectID[Organization.hackOrganizationTypeEnum]!
                // swiftlint:disable:next force_cast
                organizationType = viewContext.object(with: orgTypeObjectID) as! OrganizationType
                hack = true
            } else {
                fatalError( "Cannot Fetch organizationType object", file: #file, line: #line )
            }
            print("""
                  ORGANIZATIONTYPE: getter for \(self.shortName). \
                  Returning \(organizationType.name) \
                  on Thread = \(Thread.isMainThread ? "MAIN" : "Background")\
                  \(hack ? " after applying hack ;-())" : "")
                  """)
            return organizationType
        }
        set {
            print("""
                  ORGANIZATIONTYPE: setter for \(self.fullName). \
                  New value = \(newValue.name) \
                  on Thread = \(Thread.isMainThread ? "MAIN" : "Background")
                  """)
            if newValue.name != Organization.hackOrganizationTypeEnum.rawValue {
                print("""
                      ORGANIZATIONTYPE: setter for \(self.fullName). \
                      Unexpected new value = \(newValue.name) \
                      (\(Organization.hackOrganizationTypeEnum.rawValue) expected) \
                      on Thread = \(Thread.isMainThread ? "MAIN" : "Background")
                      """)
                ifDebugFatalError("Unexpected value for setter for organizationtype (see console)")
            }
            if organizationType_ != newValue { // avoid unnecessarily dirtying context
                organizationType_ = newValue
            }
        }
    }

	var fullName: String {
		get { return name_ ?? "DefaultPhotoClubName" }
		set { name_ = newValue }
	}

    // appends " \(town)" to fullName unless `town` is already included as a word in fullName
    // "Fotogroep Waalre" and "Aalst" returns "Fotogroep Waalre (Aalst)"
    // "Fotogroep Waalre" and "Waalre" returns "Fotogroep Waalre"
    // "Fotogroep Waalre" and "waalre" returns "Fotogroep Waalre"
    // "Fotogroep Waalre" and "to" returns "Fotogroep Waalre (to)"
    // "Fotogroep Waalre" and "Waal" returns "Fotogroep Waalre (Waal)" if you use NLP-based word matching
    @objc var fullNameTown: String { // @objc needed for SectionedFetchRequest's sectionIdentifier
        if fullName.containsWordUsingNLP(targetWord: town) {
            fullName // fullname "Fotogroep Waalre" and town "Waalre" returns "Fotogroep Waalre"
        } else {
            "\(fullName) (\(town))" // fullname "Fotogroep Aalst" with "Waalre" returns "Fotogroep Aalst (Waalre)"
        }
    }

    public var id: PhotoClubId { // public because needed for Identifiable protocol
        PhotoClubId(fullName: self.fullName, town: self.town)
    }

    var shortName: String {
        get { return shortName_ ?? "Name?" }
        set { shortName_ = newValue }
    }

	var town: String {
		get { return town_ ?? "DefaultPhotoClubTown" }  // nil shouldn't occur, but it does?
		set { town_ = newValue }
	}

    var localizedTown: String {
        /*
            LocalizedCountry is retrieved from the CoreData database, where it is not optional.
            It is calculated using the mandatory GPS coordinates using reverseGeolocation.
            During this reverseGeolocation, the string is automatically adapted to the current locale.
            Example: Paris returns localizedTown="Paris" if the device is set to Dutch.
            The value of Town is not localized and is the original value provided by the user.
            Localization may return a slightly different town: Tokyo -> suburb of Tokyo (because "Tokyo" is not used).
        */
        get { return localizedTown_ ?? "ErrorTown" }
        set { localizedTown_ = newValue}
    }

    var localizedCountry: String {
        /*
            LocalizedCountry is retrieved from the CoreData database, where it is not optional.
            It is calculated using the mandatory GPS coordinates using reverseGeolocation.
            During this reverseGeolocation, the string is automatically adapted to the current locale.
            Example: Paris returns localizedCountry="Frankrijk" if the device is set to Dutch.
        */
        get { return localizedCountry_ ?? "ErrorCountry" }
        set { localizedCountry_ = newValue}
    }

    var memberListURL: URL? { // use memberListURL for display only (memberListURL_ is the real source of truth)
        get {
            if let urlString = memberListURL_?.absoluteString {
                if let url = memberListURL_, urlString.lowercased().contains("vdhamer.com/leden2") { // site mirroring
                    return URL(string: "https://www.fotogroepwaalre.nl" + url.path + "/")
                }
            }
            return memberListURL_
        }
        set { memberListURL_ = newValue }
    }

    var coordinates: CLLocationCoordinate2D {
        get { return CLLocationCoordinate2D(latitude: latitude_, longitude: longitude_) }
        set {
            latitude_ = newValue.latitude
            longitude_ = newValue.longitude
        }
    }

    // Priority system to choose an item's remark in the appropriate language.
    // The choice depends on the current language settings of the device, and on available translations.
    var localizedRemark: String {
        let currentLangID = Locale.current.language.languageCode?.identifier // 2 (occasionally 3) letter ISO 639 code

        // We may be configured to another language (e.g. "de"), for which there is no translation.
        // Or we may be looking for EN or NL, but that one is not available.
        if currentLangID?.lowercased() == "nl" {
            if remarkNL != nil { return remarkNL! }

            let apologyNL: StringLiteralType = " [nog geen Nederlandse vertaling beschikbaar]"
            if remarkEN != nil { return remarkEN! + apologyNL}
        } else {
            if remarkEN != nil { return remarkEN! }

            let apologyEN: StringLiteralType = " [no English translation available yet]"
            if remarkNL != nil { return remarkNL! + apologyEN} // as a last resort, use Dutch (nl)
        }

        return String(localized: "No remark available.",
                      comment: "Shown below map if there is no usable remark in the OrganzationList.json file.")
        // Actually there could be a remark (from the json file) in a language other than "en" or "nl",
        // but the app doesn't store any other language yet. This may change when fixing GitHub issue #272.
    }

    // MARK: - findCreateUpdate

	// Find existing organization or create a new one
	// Update new or existing organization's attributes
    static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground of background context
                                 organizationTypeEum: OrganizationTypeEnum,
                                 idPlus: OrganizationIdPlus,
                                 website: URL? = nil,
                                 wikipedia: URL? = nil,
                                 fotobondNumber: Int16? = nil,
                                 coordinates: CLLocationCoordinate2D? = nil,
                                 pinned: Bool = false,
                                 localizedRemarks: [JSON] = []
                                ) -> Organization {

        let predicateFormat: String = "name_ = %@ AND town_ = %@" // avoid localization
        // Note that organizationType is not an identifying attribute.
        // This implies that you cannot have 2 organizations with the same Name and Town, but of a different type.
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [idPlus.fullName,
                                                    idPlus.town] )
        let fetchRequest: NSFetchRequest<Organization> = Organization.fetchRequest()
        fetchRequest.predicate = predicate
		let organizations: [Organization] = (try? context.fetch(fetchRequest)) ?? [] // EXC_BAD_ACCESS (code=1, address=0x100)

        if organizations.count > 1 { // organization exists, but there shouldn't be multiple that satify the predicate
            ifDebugFatalError("Query returned \(organizations.count) organizations named " +
                              "\(idPlus.fullName) in \(idPlus.town)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

		if let organization = organizations.first { // already exists, so make sure secondary attributes are up to date
            print("\(organization.fullNameTown): Will try to update info for organization \(organization.fullName)")
            if update(bgContext: context, organizationTypeEnum: organizationTypeEum,
                      photoClub: organization, shortName: idPlus.nickname,
                      optionalFields: (website: website, wikipedia: wikipedia,
                                       fotobondNumber: fotobondNumber),
                      coordinates: coordinates,
                      pinned: pinned,
                      localizedRemarks: localizedRemarks) {
                print("\(organization.fullNameTown): Updated info for organization \(organization.fullName)")
            }
			return organization
		} else { // have to create PhotoClub object because it doesn't exist yet
            // cannot use PhotoClub() initializer because we must use bgContext
            let entity = NSEntityDescription.entity(forEntityName: "Organization", in: context)!
            let organization = Organization(entity: entity, insertInto: context) // create new Club or Museum
            organization.fullName = idPlus.fullName // first part of ID
            organization.town = idPlus.town // second part of ID
            print("\(organization.fullNameTown): Will try to create this new organization")
            _ = update(bgContext: context, organizationTypeEnum: organizationTypeEum,
                       photoClub: organization, shortName: idPlus.nickname,
                       optionalFields: (website: website, wikipedia: wikipedia,
                                        fotobondNumber: fotobondNumber),
                       coordinates: coordinates,
                       pinned: pinned,
                       localizedRemarks: localizedRemarks)
            print("\(organization.fullNameTown): Successfully created new \(organizationTypeEum.rawValue)")
			return organization
		}
	}

	// Update non-identifying attributes/properties within existing instance of class PhotoClub
    // swiftlint:disable:next function_parameter_count cyclomatic_complexity
    private static func update(bgContext: NSManagedObjectContext,
                               organizationTypeEnum: OrganizationTypeEnum,
                               photoClub: Organization, shortName: String,
                               // swiftlint:disable:next large_tuple
                               optionalFields: (website: URL?, wikipedia: URL?,
                                                fotobondNumber: Int16?),
                               coordinates: CLLocationCoordinate2D?,
                               pinned: Bool,
                               localizedRemarks: [JSON] ) -> Bool {

		var modified: Bool = false

        // some fancy footwork because organization type info originated from other context
        let organizationType = OrganizationType.findCreateUpdate(context: bgContext,
                                                                 name: organizationTypeEnum.rawValue)

        if photoClub.organizationType_ != organizationType {
            photoClub.organizationType = organizationType
            modified = true }

        if photoClub.shortName != shortName {
            photoClub.shortName = shortName
            modified = true }

        if let website = optionalFields.website, photoClub.website != website {
            photoClub.website = website
            modified = true }

        if let wikiURL = optionalFields.wikipedia, photoClub.wikipedia != wikiURL {
            photoClub.wikipedia = wikiURL
            modified = true }

        if let fotobondNumber = optionalFields.fotobondNumber, photoClub.fotobondNumber != fotobondNumber {
            photoClub.fotobondNumber = fotobondNumber
            modified = true }

        if let coordinates, photoClub.coordinates != coordinates {
            photoClub.longitude_ = coordinates.longitude
            photoClub.latitude_ = coordinates.latitude
			modified = true }

        if photoClub.pinned != pinned {
            photoClub.pinned = pinned
            modified = true }

        for localizedRemark in localizedRemarks {
            if localizedRemark["language"].stringValue == "EN" {
                let remarkEN = localizedRemark["value"].stringValue
                if photoClub.remarkEN != remarkEN {
                    photoClub.remarkEN = remarkEN
                    modified = true
                }
            } else if localizedRemark["language"].stringValue == "NL" {
                let remarkNL = localizedRemark["value"].stringValue
                if photoClub.remarkNL != remarkNL {
                    photoClub.remarkNL = remarkNL
                    modified = true
                }
            }
        }

        if modified {
			do {
				try bgContext.save() // persist modifications in PhotoClub record
 			} catch {
                ifDebugFatalError("Update failed for photo club \(photoClub.fullName)",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, if save() fails, just continue
                return false
			}
		}
        return modified
	}

    func deleteAllMembers(context: NSManagedObjectContext) { // doesn't work ;-(
//        for member in members {
//            print("Deleting member \(member.photographer.fullName) of photo club \(self.name)")
//            context.delete(member)
//        }
//        do {
//            try context.save()
//        } catch {
//            ifDebugFatalError(Failed to delete members photo club \(self.name)",
//                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
//            /* in release mode, if deleting all members fails, just continue */
//        }
    }

}
