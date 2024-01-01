//
//  PhotoClub.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 03/07/2021.
//

import CoreData // needed for NSSet
import CoreLocation // needed for coordinate translation
import SwiftUI // for UserInterfaceSizeClass

extension PhotoClub: Comparable {

	public static func < (lhs: PhotoClub, rhs: PhotoClub) -> Bool {
		return lhs.fullName < rhs.fullName
	}

}

extension PhotoClub {

    // MARK: - getters and setters

	var members: Set<MemberPortfolio> {
		get { (members_ as? Set<MemberPortfolio>) ?? [] }
		set { members_ = newValue as NSSet }
	}

    var organizationType: OrganizationType {
        get {
            let organizationType: OrganizationType
            var hack = false

            if organizationType_ != nil {
                organizationType = organizationType_! // not nil, should be the case
            } else if Thread.isMainThread { // frantic hack to avoid fatal error
                let persistenceController = PersistenceController.shared // for Core Data
                let viewContext = persistenceController.container.viewContext
                let orgTypeObjectID: NSManagedObjectID = OrganizationType.enum2objectID[OrganizationTypeEnum.unknown]!
                // swiftlint:disable:next force_cast
                organizationType = viewContext.object(with: orgTypeObjectID) as! OrganizationType
                hack = true
            } else {
                fatalError( "Cannot Fetch organizationType object", file: #file, line: #line ) // TODO crash site
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
                  ORGANIZATIONTYPE: setter for \(self.shortName). \
                  New value = \(newValue.name) \
                  on Thread = \(Thread.isMainThread ? "MAIN" : "Background")
                  """)
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

	// Find existing organization or create a new one
	// Update new or existing organization's attributes
    static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground of background context
                                 organizationType: OrganizationTypeEnum,
                                 photoClubIdPlus: PhotoClubIdPlus,
                                 photoClubWebsite: URL? = nil, fotobondNumber: Int16? = nil, kvkNumber: Int32? = nil,
                                 coordinates: CLLocationCoordinate2D? = nil,
                                 pinned: Bool = false
                                ) -> PhotoClub {

        let predicateFormat: String = "name_ = %@ AND town_ = %@" // avoid localization
        // Note that organizationType is not an identifying attribute.
        // This implies that you cannot have 2 organizations with the same Name and Town, but of a different type.
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [photoClubIdPlus.fullName,
                                                    photoClubIdPlus.town] )
        let fetchRequest: NSFetchRequest<PhotoClub> = PhotoClub.fetchRequest()
        fetchRequest.predicate = predicate
		let organizations: [PhotoClub] = (try? context.fetch(fetchRequest)) ?? [] // nil means absolute failure

        if organizations.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("Query returned \(organizations.count) organizations named " +
                              "\(photoClubIdPlus.fullName) in \(photoClubIdPlus.town)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

		if let organization = organizations.first { // already exists, so make sure secondary attributes are up to date
            print("\(organization.fullNameTown): Will try to update info for organization \(organization.fullName)")
            if update(bgContext: context, organizationTypeEnum: organizationType,
                      photoClub: organization, shortName: photoClubIdPlus.nickname,
                      optionalFields: (photoClubWebsite: photoClubWebsite,
                                       fotobondNumber: fotobondNumber,
                                       kvkNumber: kvkNumber),
                      coordinates: coordinates,
                      pinned: pinned) {
                print("\(organization.fullNameTown): Updated info for organization \(organization.fullName)")
            }
			return organization
		} else {
            // cannot use PhotoClub() initializer because we must use bgContext
            let entity = NSEntityDescription.entity(forEntityName: "PhotoClub", in: context)!
            let organization = PhotoClub(entity: entity, insertInto: context)
            organization.fullName = photoClubIdPlus.fullName // first part of ID
            organization.town = photoClubIdPlus.town // second part of ID
            print("\(organization.fullNameTown): Will try to create new organization \(organization.fullName)")
            _ = update(bgContext: context, organizationTypeEnum: organizationType,
                       photoClub: organization, shortName: photoClubIdPlus.nickname,
                       optionalFields: (photoClubWebsite: photoClubWebsite,
                                        fotobondNumber: fotobondNumber,
                                        kvkNumber: kvkNumber),
                       coordinates: coordinates,
                       pinned: pinned)
            print("\(organization.fullNameTown): Successfully created new photo club")
			return organization
		}
	}

    // MARK: - update

	// Update non-identifying attributes/properties within existing instance of class PhotoClub
    // swiftlint:disable:next function_parameter_count
    static func update(bgContext: NSManagedObjectContext,
                       organizationTypeEnum: OrganizationTypeEnum,
                       photoClub: PhotoClub, shortName: String,
                       // swiftlint:disable:next large_tuple
                       optionalFields: (photoClubWebsite: URL?, fotobondNumber: Int16?, kvkNumber: Int32?),
                       coordinates: CLLocationCoordinate2D?,
                       pinned: Bool) -> Bool {

		var modified: Bool = false

        if let organizationTypeObjectID = OrganizationType.enum2objectID[organizationTypeEnum] {
            let managedObject: NSManagedObject = bgContext.object(with: organizationTypeObjectID)
            // swiftlint:disable:next force_cast
            let organizationType: OrganizationType = managedObject as! OrganizationType
            if photoClub.organizationType_ != nil, photoClub.organizationType != organizationType { // toggling value??
                ifDebugFatalError("An organization's 'type' should only be initialized once")
            }
            photoClub.organizationType = OrganizationType.findCreateUpdate(context: bgContext, // TODO check me
                                                                           name: organizationTypeEnum.rawValue
            )
        } else { // this shouldn't fail...
            ifDebugFatalError("Failed to retrieve organizationType from within background thread.")
            // ...and not sure this will save the day, but give all records a type .club to prevent a crash in PRD code
            photoClub.organizationType = OrganizationType.findCreateUpdate(context: bgContext,
                                                                           name: OrganizationTypeEnum.unknown.rawValue
            )
        }

        if photoClub.shortName != shortName {
            photoClub.shortName = shortName
            modified = true }

        if let website = optionalFields.photoClubWebsite, photoClub.photoClubWebsite != website {
            photoClub.photoClubWebsite = website
            modified = true }

        if let fotobondNumber = optionalFields.fotobondNumber, photoClub.fotobondNumber != fotobondNumber {
            photoClub.fotobondNumber = fotobondNumber
            modified = true }

        if let kvkNumber = optionalFields.kvkNumber, photoClub.kvkNumber != kvkNumber {
            photoClub.kvkNumber = kvkNumber
            modified = true }

        if let coordinates, photoClub.coordinates != coordinates {
            photoClub.longitude_ = coordinates.longitude
            photoClub.latitude_ = coordinates.latitude
			modified = true }

        if photoClub.pinned != pinned {
            photoClub.pinned = pinned
            modified = true }

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
