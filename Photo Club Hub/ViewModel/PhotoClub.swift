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

	var members: Set<MemberPortfolio> {
		get { (members_ as? Set<MemberPortfolio>) ?? [] }
		set { members_ = newValue as NSSet }
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

    var country: String {
        /*
            This currently reads the value from the Core Data store.
            That value should be non-nil because of a default.
            Idea is to use Core Location to look up coordinates (if available) and overwrite
            the value in the database. This CL functionality is asynchronous.
            The functionality can be triggered by a static function PhotoClub.RefreshCountries, but that
            would need to await completion to avoid overlapping calls to Core Location.
         */
        get { return country_ ?? "ErrorCountry" }
        set { country_ = newValue}
    }

    var country2: String { // TODO
        get {
            var country = "UnknownCountry"
            let geocoder = CLGeocoder()

            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Failed to retrieve address: \(error!)")
                    return
                }

                if let placemarks, let placemark = placemarks.first, let country = placemark.country {
                    print(placemark.address!)
                    self.country = placemark.country!
                    return
                } else {
                    print("No Matching Address Found")
                    return
                }
            })
            return country
        }
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

	// Find existing object or create a new object
	// Update existing attributes or fill the new object
    static func findCreateUpdate(context: NSManagedObjectContext, // can be foreground of background context
                                 photoClubIdPlus: PhotoClubIdPlus,
                                 photoClubWebsite: URL? = nil, fotobondNumber: Int16? = nil, kvkNumber: Int32? = nil,
                                 coordinates: CLLocationCoordinate2D? = nil,
                                 pinned: Bool = false
                                ) -> PhotoClub {

        let predicateFormat: String = "name_ = %@ AND town_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat,
                                    argumentArray: [photoClubIdPlus.fullName,
                                                    photoClubIdPlus.town] )
        let fetchRequest: NSFetchRequest<PhotoClub> = PhotoClub.fetchRequest()
        fetchRequest.predicate = predicate
		let photoClubs: [PhotoClub] = (try? context.fetch(fetchRequest)) ?? [] // nil means absolute failure

        if photoClubs.count > 1 { // there is actually a Core Data constraint to prevent this
            ifDebugFatalError("Query returned \(photoClubs.count) photoclubs named " +
                              "\(photoClubIdPlus.fullName) in \(photoClubIdPlus.town)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

		if let photoClub = photoClubs.first { // already exists, so make sure secondary attributes are up to date
            print("\(photoClub.fullNameTown): Will try to update info for photo club \(photoClub.fullName)")
            if update(bgContext: context, photoClub: photoClub,
                      shortName: photoClubIdPlus.nickname,
                      optionalFields: (photoClubWebsite: photoClubWebsite,
                                       fotobondNumber: fotobondNumber,
                                       kvkNumber: kvkNumber),
                      coordinates: coordinates,
                      pinned: pinned) {
                print("\(photoClub.fullNameTown): Updated info for photo club \(photoClub.fullName)")
            }
			return photoClub
		} else {
            // cannot use PhotoClub() initializer because we must use bgContext
            let entity = NSEntityDescription.entity(forEntityName: "PhotoClub", in: context)!
            let photoClub = PhotoClub(entity: entity, insertInto: context)
            photoClub.fullName = photoClubIdPlus.fullName // first part of ID
            photoClub.town = photoClubIdPlus.town // second part of ID
            print("\(photoClub.fullNameTown): Will try to create new photo club")
            _ = update(bgContext: context, photoClub: photoClub,
                       shortName: photoClubIdPlus.nickname,
                       optionalFields: (photoClubWebsite: photoClubWebsite,
                                        fotobondNumber: fotobondNumber,
                                        kvkNumber: kvkNumber),
                       coordinates: coordinates,
                       pinned: pinned)
            print("\(photoClub.fullNameTown): Created new photo club")
			return photoClub
		}
	}

	// Update non-identifying attributes/properties within existing instance of class PhotoClub
    // swiftlint:disable:next function_parameter_count
    static func update(bgContext: NSManagedObjectContext, photoClub: PhotoClub, shortName: String,
                       // swiftlint:disable:next large_tuple
                       optionalFields: (photoClubWebsite: URL?, fotobondNumber: Int16?, kvkNumber: Int32?),
                       coordinates: CLLocationCoordinate2D?, pinned: Bool) -> Bool {

		var modified: Bool = false

        if photoClub.shortName != shortName {
            photoClub.shortName = shortName
            modified = true
        }
        if let website = optionalFields.photoClubWebsite, photoClub.photoClubWebsite != website {
			photoClub.photoClubWebsite = website
			modified = true
		}
        if let fotobondNumber = optionalFields.fotobondNumber, photoClub.fotobondNumber != fotobondNumber {
			photoClub.fotobondNumber = fotobondNumber
			modified = true
		}
        if let kvkNumber = optionalFields.kvkNumber, photoClub.kvkNumber != kvkNumber {
			photoClub.kvkNumber = kvkNumber
			modified = true
		}
        if let coordinates, photoClub.coordinates != coordinates {
            photoClub.longitude_ = coordinates.longitude
            photoClub.latitude_ = coordinates.latitude
			modified = true
		}
        if photoClub.pinned != pinned {
            photoClub.pinned = pinned
            modified = true
        }
		if modified {
			do {
				try bgContext.save()
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
