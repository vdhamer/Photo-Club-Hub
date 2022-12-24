//
//  PhotoClub.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 03/07/2021.
//

import CoreData // needed for NSSet
import CoreLocation // needed for coordinate translation

extension PhotoClub: Comparable {

	public static func < (lhs: PhotoClub, rhs: PhotoClub) -> Bool {
		return lhs.name < rhs.name
	}

}

extension PhotoClub {

	var members: Set<MemberPortfolio> {
		get { (members_ as? Set<MemberPortfolio>) ?? [] }
		set { members_ = newValue as NSSet }
	}

	var name: String {
		get { return name_ ?? "DefaultPhotoClubName" }
		set { name_ = newValue }
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

    var priority: Int16 {
        get { return priority_ }
        set { priority_ = newValue}
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
    static func findCreateUpdate(context: NSManagedObjectContext,
                                 name: String, town: String,
                                 photoClubWebsite: URL? = nil, fotobondNumber: Int16? = nil, kvkNumber: Int32? = nil,
                                 coordinates: CLLocationCoordinate2D? = nil,
                                 priority: Int16? = nil
                                ) -> PhotoClub {
        let predicateFormat: String = "name_ = %@" // avoid localization
        let request: NSFetchRequest = fetchRequest(predicate: NSPredicate(format: predicateFormat, name))

		let photoClubs: [PhotoClub] = (try? context.fetch(request)) ?? [] // nil means absolute failure

		if let photoClub = photoClubs.first { // already exists, so make sure secondary attributes are up to date
            if update(context: context, photoClub: photoClub, town: town,
                   optionalFields: (photoClubWebsite: photoClubWebsite,
                                    fotobondNumber: fotobondNumber,
                                    kvkNumber: kvkNumber),
                      coordinates: coordinates,
                      priority: priority) {
                            print("Updated info for photo club \(photoClub.name)")
            }
			return photoClub
		} else {
			let photoClub = PhotoClub(context: context) // create new PhotoClub object
			photoClub.name = name
            _ = update(context: context, photoClub: photoClub, town: town,
                   optionalFields: (photoClubWebsite: photoClubWebsite,
                                    fotobondNumber: fotobondNumber,
                                    kvkNumber: kvkNumber),
                   coordinates: coordinates,
                   priority: priority)
            print("Created new photo club \(photoClub.name) in \(photoClub.town), \(photoClub.country)")
			return photoClub
		}
	}

	// Update non-identifying attributes/properties within existing instance of class PhotoClub
    // swiftlint:disable:next function_parameter_count
    static func update(context: NSManagedObjectContext, photoClub: PhotoClub, town: String,
                       // swiftlint:disable:next large_tuple
                       optionalFields: (photoClubWebsite: URL?, fotobondNumber: Int16?, kvkNumber: Int32?),
                       coordinates: CLLocationCoordinate2D?, priority: Int16?) -> Bool {

		var modified: Bool = false

		if photoClub.town != town {
			photoClub.town = town
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
        if let priority, photoClub.priority != priority {
            photoClub.priority_ = priority
            modified = true
        }
		if modified {
			do {
				try context.save()
 			} catch {
                fatalError("Update failed for photo club \(photoClub.name)")
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
//            fatalError("Failed to delete members photo club \(self.name)")
//        }
    }

}

extension PhotoClub { // convenience function

	static func fetchRequest(predicate: NSPredicate) -> NSFetchRequest<PhotoClub> {
		let request = NSFetchRequest<PhotoClub>(entityName: "PhotoClub")
		request.predicate = predicate // WHERE part of the SQL query
		request.sortDescriptors = [NSSortDescriptor(key: "priority_", ascending: true)] // ORDER BY part of the SQL query
		return request
	}

}
