//
//  Photographer.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 03/07/2021.
//

import CoreData // needed for NSSet

extension Photographer: Comparable {

	public static func < (lhs: Photographer, rhs: Photographer) -> Bool {
		return (lhs.fullName < rhs.fullName)
	}

}

extension Photographer {

	var memberships: Set<MemberPortfolio> {
		get { (memberships_ as? Set<MemberPortfolio>) ?? [] }
		set { memberships_ = newValue as NSSet }
	}

	private(set) var givenName: String {
		get { return givenName_! }
		set { givenName_ = newValue }
	}

	private(set) var familyName: String {
		get { return familyName_! }
		set { familyName_ = newValue }
	}

    var fullName: String {
        return givenName + " " + familyName
    }

    var memberRolesAndStatus: MemberRolesAndStatus {
        get { // conversion from Bool to dictionary
            return MemberRolesAndStatus(role: [:], stat: [
                .deceased: isDeceased,
                .deviceOwner: isDeviceOwner]
            )
        }
        set { // merge newValue with existing dictionary
            if let newBool = newValue.stat[.deceased] {
                isDeceased = newBool!
            }
            if let newBool = newValue.stat[.deviceOwner] {
                isDeviceOwner = newBool!
            }
        }
    }

    var phoneNumber: String {
        get { return phoneNumber_ ?? ""}
        set { phoneNumber_ = newValue}
    }

    var eMail: String {
        get { return eMail_ ?? "" }
        set { eMail_ = newValue}
    }

    // Find existing object and otherwise create a new object
    // Update existing attributes or fill the new object
    static func findCreateUpdate(context: NSManagedObjectContext,
                                 givenName: String, familyName: String,
                                 memberRolesAndStatus: MemberRolesAndStatus,
                                 phoneNumber: String? = nil, eMail: String? = nil,
                                 photographerWebsite: URL? = nil, bornDT: Date? = nil) -> Photographer {
        let predicateFormat: String = "givenName_ = %@ AND familyName_ = %@" // avoid localization
        let request = fetchRequest(predicate: NSPredicate(format: predicateFormat, givenName, familyName))

        let photographers: [Photographer] = (try? context.fetch(request)) ?? [] // nil means absolute failure

        if let photographer = photographers.first { // already exists, so make sure secondary attributes are up to date
            if update(context: context, photographer: photographer,
                      memberRolesAndStatus: memberRolesAndStatus,
                      phoneNumber: phoneNumber, eMail: eMail,
                      photographerWebsite: photographerWebsite, bornDT: bornDT) {
                print("Updated info for photographer \(photographer.fullName)")
            }
            return photographer
        } else {
            let photographer = Photographer(context: context) // new record in database
            photographer.givenName = givenName
            photographer.familyName = familyName
            _ = update(context: context, photographer: photographer, memberRolesAndStatus: memberRolesAndStatus,
                       phoneNumber: phoneNumber, eMail: eMail, photographerWebsite: photographerWebsite, bornDT: bornDT)
            print("Created new photographer \(photographer.fullName)")
            return photographer
        }
    }

	// Find existing object and otherwise create a new object
	// Update existing attributes or fill the new object
    /*
    static func findCreateUpdate(context: NSManagedObjectContext,
                                 givenName: String, familyName: String,
                                 memberRolesAndStatus: MemberRolesAndStatus,
                                 isDeceased: Bool? = nil, isDeviceOwner: Bool? = nil,
                                 phoneNumber: String? = nil, eMail: String? = nil,
                                 photographerWebsite: URL? = nil, bornDT: Date? = nil
                                ) -> Photographer {
        let predicateFormat: String = "givenName_ = %@ AND familyName_ = %@" // avoid localization
		let request = fetchRequest(predicate: NSPredicate(format: predicateFormat, givenName, familyName))

		let photographers: [Photographer] = (try? context.fetch(request)) ?? [] // nil means absolute failure

		if let photographer = photographers.first { // already exists, so make sure secondary attributes are up to date
            if update(context: context, photographer: photographer,
                      isDeceased: isDeceased, isDeviceOwner: isDeviceOwner,
                      phoneNumber: phoneNumber, eMail: eMail,
                      photographerWebsite: photographerWebsite, bornDT: bornDT) {
                print("Updated info for photographer \(photographer.fullName)")
            }
			return photographer
		} else {
			let photographer = Photographer(context: context) // new record in database
			photographer.givenName = givenName
			photographer.familyName = familyName
			photographer.isDeceased = isDeceased ?? false
            photographer.isDeviceOwner = isDeviceOwner ?? false
            photographer.phoneNumber = phoneNumber ?? ""
            photographer.eMail = eMail ?? ""
            photographer.bornDT = bornDT
            _ = update(context: context, photographer: photographer,
                       phoneNumber: phoneNumber, eMail: eMail, photographerWebsite: photographerWebsite, bornDT: bornDT)
            print("Created new photographer \(photographer.fullName)")
			return photographer
		}
	}*/

	// Update non-identifying attributes/properties within existing instance of class PhotoClub
    static func update(context: NSManagedObjectContext, photographer: Photographer,
                       memberRolesAndStatus: MemberRolesAndStatus,
                       phoneNumber: String? = nil, eMail: String? = nil,
                       photographerWebsite: URL? = nil, bornDT: Date? = nil) -> Bool {

		var modified: Bool = false

        if let isDeceased = memberRolesAndStatus.stat[.deceased], photographer.isDeceased != isDeceased {
            photographer.memberRolesAndStatus.stat[.deceased] = isDeceased
			modified = true
		}

        if let isDeviceOwner = memberRolesAndStatus.stat[.deviceOwner], photographer.isDeviceOwner != isDeviceOwner {
            photographer.memberRolesAndStatus.stat[.deviceOwner] = isDeviceOwner
            modified = true
        }

        if let bornDT = bornDT, photographer.bornDT != bornDT {
			photographer.bornDT = bornDT
			modified = true
		}

        if let phoneNumber = phoneNumber, photographer.phoneNumber != phoneNumber {
            photographer.phoneNumber = phoneNumber
            modified = true
        }

        if let eMail = eMail, photographer.eMail != eMail {
            photographer.eMail = eMail
            modified = true
        }

        if let photographerWebsite = photographerWebsite, photographer.photographerWebsite != photographerWebsite {
            photographer.photographerWebsite = photographerWebsite
            modified = true
        }

		if modified {
			do {
				try context.save()
			} catch {
                fatalError("Update failed for photographer \(photographer.fullName)")
			}
		}
        return modified
	}

}

extension Photographer { // convenience function

	static func fetchRequest(predicate: NSPredicate) -> NSFetchRequest<Photographer> {
		let request = NSFetchRequest<Photographer>(entityName: "Photographer")
		request.predicate = predicate // WHERE part of the SQL query
		request.sortDescriptors = [NSSortDescriptor(key: "givenName_", ascending: true),
								   NSSortDescriptor(key: "familyName_", ascending: true)] // ORDER BY part of the SQL query
		return request
	}

}
