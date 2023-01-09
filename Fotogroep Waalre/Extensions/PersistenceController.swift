//
//  PersistenceController.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 27/06/2021.
//

import CoreData
import CoreLocation // needed for coordinate translation

struct PersistenceController {
	static let shared = PersistenceController()
    let storename = String("Fotogroep Waalre") // Used as Core Data database name - not localized.

	static var preview: PersistenceController = {
		let result = PersistenceController(inMemory: true)
		let viewContext = result.container.viewContext
		for index in 1...10 {
            let memberRolesAndStatus =  MemberRolesAndStatus( role: [.chairman: (index==1),
                                                                     .treasurer: (index==2)],
                                                              stat: [.deceased: ((index % 4) == 0),
                                                                     .former: ((index % 4) == 1)]
            )
			let photographer = Photographer.findCreateUpdate(
                context: viewContext, givenName: "Jan",
                familyName: "D'Eau\(index)",
                memberRolesAndStatus: memberRolesAndStatus,
                phoneNumber: "06-12345678",
                eMail: "Jan.D.Eau\(index)@example.com",
                photographerWebsite: URL(string: "https://www.example.com/JanDEau\(index)"),
                bornDT: Date() - Double.random(in: 365*24*3600 ... 75*365*24*3600)
            )
            let photoClub = PhotoClub.findCreateUpdate(context: viewContext,
                                                       name: "PhotoClub\(index)",
                                                       shortName: "Club\(index)",
                                                       town: "Town\(index)",
                                                       photoClubWebsite: URL(string: "http://www.example.com/\(index)"),
                                                       fotobondNumber: Int16(index*1111),
                                                       kvkNumber: Int32(100+index),
                                                       coordinates: CLLocationCoordinate2D( // spread around BeNeLux
                                                            latitude: 51.39184 + Double.random(in: -2.0 ... 2.0),
                                                            longitude: 5.46144 + Double.random(in: -2.0 ... 1.0)),
                                                       priority: Int16(11-index)) // low number gets high priority
			let memberPortfolio = MemberPortfolio.findCreateUpdate(context: viewContext,
                                                 photoClub: photoClub, photographer: photographer,
                                                 memberRolesAndStatus: memberRolesAndStatus
            )
		}

		do {
			try viewContext.save()
		} catch {
			// Replace this implementation with code to handle the error appropriately.
			// fatalError() causes the application to generate a crash log and terminate.
			// You should not use this function in a shipping application, although it may be useful during development.
			let nsError = error as NSError
			fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
		}
		return result
	}()

	let container: NSPersistentContainer

	init(inMemory: Bool = false) {
		container = NSPersistentContainer(name: "Fotogroep_Waalre_2") // name of .xcdatamodel
		if inMemory {
			container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
		}

        // https://beckyhansmeyer.com/tag/core-data/ and https://developer.apple.com/videos/play/wwdc2021/10017
        guard let description = container.persistentStoreDescriptions.first else {
                fatalError("###\(#function): Failed to retrieve a persistent store description.")
            }
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        // next line was added to the template code for PersistenceController in iOS 15.2
        // it is needed to refresh the display when online content was merged to the core data database
        // but gives warning "View context accessed for persistent container <name> with no stores loaded
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (_ storeDescription, error) in
			if let error = (error as NSError?) {
				// Replace this implementation with code to handle the error appropriately.
				// fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application,
                // although it may be useful during development.

				/*
				Typical reasons for an error here include:
				* The parent directory does not exist, cannot be created, or disallows writing.
				* The persistent store is not accessible, due to permissions or data protection when the device is locked.
				* The device is out of space.
				* The store could not be migrated to the current model version.
				Check the error message to determine what the actual problem was.
				*/
				fatalError("Unresolved error \(error), \(error.userInfo)")
            }
		})
	}

    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
            }
        }
    }
}
