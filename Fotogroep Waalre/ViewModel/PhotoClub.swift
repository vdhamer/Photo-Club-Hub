//
//  PhotoClub.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 03/07/2021.
//

import CoreData // needed for NSSet
import CoreLocation // needed for coordinate translation
import SwiftUI
import Foundation

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

    @objc var fullNameTown: String { // objc needed for SectionedFetchRequest's sectionIdentifier
        "\(fullName) (\(town))"
    }

    public var id: PhotoClubId { // public because needed for Identifiable protocol
        PhotoClubId(fullName: self.fullName, town: self.town)
    }

    var shortName: String {
        get { return shortName_ ?? "Name?" }
        set { shortName_ = newValue }
    }

    func nameOrShortName(horSizeClass: UserInterfaceSizeClass?) -> String {
        // full photo club name on iPad and iPhone 14 Plus or Pro Max only
        guard horSizeClass != nil else { return shortName } // don't know size of display
        return (horSizeClass! == UserInterfaceSizeClass.compact) ? shortName : fullName
    }

	var town: String {
		get { return town_ ?? "DefaultPhotoClubTown" }  // nil shouldn't occur, but it does?
		set { town_ = newValue }
	}

    var country: String {
        /*
            This currently reads the value from the Core Data store.
            That value should be non-nill because of a default.
            Idea is to use Core Location to look up coordinates (if available) and overwrite
            the value in the database. This CL functionality is asynchronous.
            The functionality can be triggered by a static function PhotoClub.RefreshCountries, but that
            would need to await completion to avoid overlapping calls to Core Location.
         */
        get { return country_ ?? "ErrorCountry" }
        set { country_ = newValue}
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
        let request = fetchRequest(predicate: NSPredicate( format: predicateFormat,
                                                           argumentArray: [photoClubIdPlus.fullName,
                                                                          photoClubIdPlus.town] )
                                  )

		let photoClubs: [PhotoClub] = (try? context.fetch(request)) ?? [] // nil means absolute failure
        if photoClubs.count > 1 {
            ifDebugFatalError("Query returned \(photoClubs.count) photoclub(s) named " +
                              "\(photoClubIdPlus.fullName) in \(photoClubIdPlus.town)",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            // in release mode, log that there are multiple clubs, but continue using the first one.
        }

		if let photoClub = photoClubs.first { // already exists, so make sure secondary attributes are up to date
            if update(bgContext: context, photoClub: photoClub,
                      shortName: photoClubIdPlus.nickname,
                      optionalFields: (photoClubWebsite: photoClubWebsite,
                                       fotobondNumber: fotobondNumber,
                                       kvkNumber: kvkNumber),
                      coordinates: coordinates,
                      pinned: pinned) {
                            print("Updated info for photo club \(photoClub.fullName)")
            }
			return photoClub
		} else {
            // cannot use PhotoClub() initializer because we must use bgContext
            let entity = NSEntityDescription.entity(forEntityName: "PhotoClub", in: context)!
            let photoClub = PhotoClub(entity: entity, insertInto: context)
            photoClub.fullName = photoClubIdPlus.fullName // first part of ID
            photoClub.town = photoClubIdPlus.town // second part of ID
            _ = update(bgContext: context, photoClub: photoClub,
                       shortName: photoClubIdPlus.nickname,
                       optionalFields: (photoClubWebsite: photoClubWebsite,
                                        fotobondNumber: fotobondNumber,
                                        kvkNumber: kvkNumber),
                       coordinates: coordinates,
                       pinned: pinned)
            print("""
                  \(photoClubIdPlus.fullNameTown): \
                  Created new photo club
                  """)
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

extension PhotoClub { // convenience function

	static func fetchRequest(predicate: NSPredicate) -> NSFetchRequest<PhotoClub> {
		let request = NSFetchRequest<PhotoClub>(entityName: "PhotoClub")
		request.predicate = predicate // WHERE part of the SQL query
		request.sortDescriptors = [NSSortDescriptor(key: "pinned", ascending: true)] // ORDER BY part of the SQL query
		return request
	}

}
