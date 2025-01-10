//
//  PersistenceController.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 27/06/2021.
//

import CoreData
import CoreLocation // needed for coordinate translation

struct PersistenceController {
	static let shared = PersistenceController()

	let container: NSPersistentContainer

	init(inMemory: Bool = false) {
		container = NSPersistentContainer(name: "Photo_Club_Hub") // name of .xcdatamodel
		if inMemory {
			container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
		}

        // https://beckyhansmeyer.com/tag/core-data/ and https://developer.apple.com/videos/play/wwdc2021/10017
        guard let description = container.persistentStoreDescriptions.first else {
            ifDebugFatalError("###\(#function): Failed to retrieve a persistent store description.")
            return
        }
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        // next line was added to the template code for PersistenceController in iOS 15.2
        // it is needed to refresh the display when online content was merged to the core data database
        // but gives warning "View context accessed for persistent container <name> with no stores loaded
        container.loadPersistentStores { _, error in
			if let error = (error as NSError?) {
				fatalError("Unresolved error \(error), \(error.userInfo)") // don't know how to recover
            }
		}
        container.viewContext.automaticallyMergesChangesFromParent = true
	}

    func save() {
        let context = container.viewContext

        do {
            if context.hasChanges {
                try context.save()
            }
        } catch {
            ifDebugFatalError("Core Data save() failed on main thread.")
        }

    }

    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for index in 1...10 {
            let memberRolesAndStatus =  MemberRolesAndStatus( roles: [.chairman: (index==1),
                                                                      .treasurer: (index==2)],
                                                              status: [.deceased: ((index % 4) == 0),
                                                                       .former: ((index % 4) == 1)]
            )
            let organization = Organization.findCreateUpdate(
                context: viewContext, // on main thread
                organizationTypeEnum: .club,
                idPlus: OrganizationIdPlus(
                    fullName: "PhotoClub\(index)",
                    town: "Town\(index)",
                    nickname: "ClubNick\(index)"
                ),
                coordinates: CLLocationCoordinate2D( // spread around BeNeLux
                    latitude: 51.39184 + Double.random(in: -2.0 ... 2.0),
                    longitude: 5.46144 + Double.random(in: -2.0 ... 1.0)),
                optionalFields: OrganizationOptionalFields(
                    organizationWebsite: URL(string: "http://www.example.com/\(index)"),
                    fotobondNumber: Int16(index*1111)
                ),
                pinned: (index % 4 == 0)
            )
            let photographer = Photographer.findCreateUpdate(
                context: viewContext, // on main thread
                personName: PersonName(givenName: "Jan", infixName: "D'", familyName: "Eau\(index)"),
                optionalFields: PhotographerOptionalFields(
                    bornDT: Date() - Double.random(in: 365*24*3600 ... 75*365*24*3600),
                    isDeceased: memberRolesAndStatus.isDeceased(),
                    photographerWebsite: URL(string: "https://www.example.com/JanDEau\(index)"),
                    photographerImage: nil
                )
            )
            let memberPortfolio = MemberPortfolio.findCreateUpdate(
                bgContext: viewContext,
                organization: organization,
                photographer: photographer,
                optionalFields: MemberOptionalFields( memberRolesAndStatus: memberRolesAndStatus )
            )
        }

        do {
            try viewContext.save() // persist sample data in persistence controller
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)") // preview cannot occur in shipping code
        }
        return result
    }()

}
