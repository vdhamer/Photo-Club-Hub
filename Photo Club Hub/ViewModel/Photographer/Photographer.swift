//
//  Photographer.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 03/07/2021.
//

import CoreData // needed for NSSet

extension Photographer: Comparable {

	public static func < (lhs: Photographer, rhs: Photographer) -> Bool {
		return (lhs.fullNameFirstLast < rhs.fullNameFirstLast)
	}

}

extension Photographer {

    @available(*, unavailable)
    convenience init() {
        fatalError("init() is not available. Use .findCreateUpdate instead.")
    }

    public var photographerKeywords: Set<PhotographerKeyword> {
        (photographerKeywords_ as? Set<PhotographerKeyword>) ?? []
    }

	var memberships: Set<MemberPortfolio> {
		(memberships_ as? Set<MemberPortfolio>) ?? []
	}

	fileprivate(set) public var givenName: String {
		get { return givenName_ ?? "MissingGivenName" }
		set { givenName_ = newValue }
	}

    fileprivate(set) public var infixName: String { // "van" in names like "Jan van Doesburg"
        get { return infixName_ ?? "MissingInfixName" } // Should never happen. CoreData defaults to empty string.
        set { infixName_ = newValue }
    }

    fileprivate(set) public var familyName: String {
		get { return familyName_ ?? "MissingFamilyName" }
		set { familyName_ = newValue }
	}

    var fullNameFirstLast: String { // "John Doe" or "Jan van Doesburg"
        let infixName = self.infixName.isEmpty ? " " : " \(self.infixName) " // " van " in names like "Jan van Doesburg"
        return givenName + infixName + familyName
    }

    var fullNameLastFirst: String { // "Doe, John" or "Doesburg, Jan van"
        let infixName = self.infixName.isEmpty ? "" : " \(self.infixName)" // "van" in names like "Jan van Doesburg"
        return familyName + ", " + givenName + infixName
    }

    var memberRolesAndStatus: MemberRolesAndStatus {
        get { // conversion from Bool to dictionary
            return MemberRolesAndStatus(roles: [:], status: [
                .deceased: isDeceased]
            )
        }
        set { // merge newValue with existing dictionary
            if let newBool = newValue.status[.deceased] {
                isDeceased = newBool!
            }
        }
    }

    var isAlive: Bool {
        !isDeceased
    }

    // Find existing object and otherwise create a new object
    // Update existing attributes or fill the new object
    public static func findCreateUpdate(context: NSManagedObjectContext, // foreground or background context
                                        personName: PersonName,
                                        optionalFields: PhotographerOptionalFields = PhotographerOptionalFields()
                                       ) -> Photographer {
        let predicateFormat: String = "givenName_ = %@ AND infixName_ = %@ AND familyName_ = %@" // avoid localization
        let predicate = NSPredicate(format: predicateFormat, argumentArray: [
            personName.givenName, personName.infixName, personName.familyName ])
        let fetchRequest: NSFetchRequest<Photographer> = Photographer.fetchRequest()
        fetchRequest.predicate = predicate
        let photographers: [Photographer] = (try? context.fetch(fetchRequest)) ?? [] // nil means absolute failure

        if photographers.count == 0 {
            print("Query could not find a photographer named " +
                  "\(personName.givenName) " +
                  "\(personName.infixName.isEmpty ? "" : "\(personName.infixName) ")\(personName.familyName)")
        }

        if photographers.count > 1 { // there is actually a Core Data constraint to prevent this
            let givenName = personName.givenName
            let infixName = personName.infixName
            let familyName = personName.familyName
            ifDebugPrint("Query returned \(photographers.count) photographers named " +
                         "\(givenName) " + "\(infixName.isEmpty ? "" : "\(infixName) ")\(familyName)")
        }

        if let photographer = photographers.first {
            // already exists, so make sure secondary attributes are up to date
            let wasUpdated = update(bgContext: context, photographer: photographer,
                                    optionalFields: optionalFields)
            if wasUpdated {
                print("Updated info for photographer <\(photographer.fullNameFirstLast)>")
            } else {
                print("No changes for photographer <\(photographer.fullNameFirstLast)>")
            }
            return photographer
        } else {
            // doesn't exist yet, so add new photographer
            let entity = NSEntityDescription.entity(forEntityName: "Photographer", in: context)!
            let photographer = Photographer(entity: entity, insertInto: context) // background: use special .init()
            photographer.givenName = personName.givenName
            photographer.infixName = personName.infixName
            photographer.familyName = personName.familyName
            _ = update(bgContext: context,
                       photographer: photographer,
                       optionalFields: optionalFields)
            // don't log whether attribbutes have been updated if it is a new photographer
            print("Successfully created new photographer <\(photographer.fullNameFirstLast)>")
            return photographer
        }
    }

	// Update non-identifying properties within existing instance of class Photographer
    // Returns whether any of the non-identifying properties were updated.
    fileprivate static func update(bgContext: NSManagedObjectContext,
                                   photographer: Photographer,
                                   optionalFields: PhotographerOptionalFields) -> Bool {

        // following are fields in PhotographerOptionalFields type
        if optionalFields.bornDT != nil, photographer.bornDT != optionalFields.bornDT {
            photographer.bornDT = optionalFields.bornDT
        }

        if let isDeceased = optionalFields.isDeceased, photographer.isDeceased != optionalFields.isDeceased {
            photographer.memberRolesAndStatus.status[.deceased] = isDeceased
        }

        if let newWebsite = optionalFields.photographerWebsite, photographer.photographerWebsite != newWebsite {
            photographer.photographerWebsite = newWebsite
        }

        if let newImage = optionalFields.photographerImage, photographer.photographerImage != newImage {
            photographer.photographerImage = newImage
        }

        for photographerKeywordJSON in optionalFields.photographerKeywords {
            let photographerKeywordID = photographerKeywordJSON.stringValue
            let keyword = Keyword.findCreateUpdateUndefStandard(context: bgContext,
                                                                id: photographerKeywordID,
                                                                name: [],
                                                                usage: [])
            _ = PhotographerKeyword.findCreateUpdate(context: bgContext,
                                                     photographer: photographer,
                                                     keyword: keyword)
        }

        var hasChanges: Bool = bgContext.hasChanges
        if hasChanges && Settings.extraCoreDataSaves {
			do {
				try bgContext.save() // persist updated information about a photographer
                hasChanges = false // update may be because of earlier update
			} catch {
                ifDebugFatalError("Update failed for photographer <\(photographer.fullNameFirstLast)>",
                                  file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
                // in release mode, if the data cannot be saved, log this and continue.
			}
		}
        return hasChanges
	}

}
