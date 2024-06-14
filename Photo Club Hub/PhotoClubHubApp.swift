//
//  PhotoClubHubApp.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 20/06/2021.
//

import SwiftUI
import CoreData // for ManagedObjectContext

@main
struct PhotoClubHubApp: App {

    static let leaveEmpty = false // leaveEmpty clears the existing database and skips loading any  data on app startup
    @Environment(\.scenePhase) var scenePhase
    private static let resetKey = "2.6.2 forced data reset performed"

    init() {
        // Core Data settings
        let persistenceController = PersistenceController.shared // for Core Data
        let viewContext = persistenceController.container.viewContext // "associated with the main application queue"
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.undoManager = nil // nil by default on iOS
        viewContext.shouldDeleteInaccessibleFaults = true

        // update version number shown in iOS Settings
        UserDefaults.standard.set(Bundle.main.fullVersion, forKey: "version_preference")

        if ((AppVersion() >= AppVersion("2.6.2")) // starting with release 2.6.2, erase the database
            && (!UserDefaults.standard.bool(forKey: PhotoClubHubApp.resetKey))) // but do so only once
            || PhotoClubHubApp.leaveEmpty { // and also ease if we are in leaveEmpty mode for testing
            PhotoClubHubApp.deleteAllCoreDataObjects()
        }

        OrganizationType.initConstants() // insert contant records into OrganizationType table if needed
    }

    var body: some Scene {
        WindowGroup {
            PreludeView(leaveEmpty: PhotoClubHubApp.leaveEmpty)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext) // main queue!
                .onAppear {
                    guard !PhotoClubHubApp.leaveEmpty else { return }
                    PhotoClubHubApp.loadClubsAndMembers()
                }
        }
        .onChange(of: scenePhase) { // pre-iOS 17 there was 1 param. Since iOS 17 it is 0 or 2.
            PersistenceController.shared.save() // persist data when app moves to background
        }
    }

}

extension PhotoClubHubApp {

    static func loadClubsAndMembers() {

        if !PhotoClubHubApp.leaveEmpty {
            // load list of photo clubs and museums from root.Level1.json file
            let level1BackgroundContext = PersistenceController.shared.container.newBackgroundContext()
            level1BackgroundContext.name = "root.level1.json"
            level1BackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            level1BackgroundContext.automaticallyMergesChangesFromParent = true // to push ObjectTypes to bgContext?
            _ = RootLevel1JsonReader(bgContext: level1BackgroundContext, // read root.Level1.json file
                                     useOnlyFile: false)
        }

        // warning: following clubs rely on Level 1 file for GPS coordiantes

        if !PhotoClubHubApp.leaveEmpty {
            // load test member(s) of Fotogroep Bellus Imago
            let bellusBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
            bellusBackgroundContext.name = "Bellus Imago"
            bellusBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            bellusBackgroundContext.automaticallyMergesChangesFromParent = true
            _ = BellusImagoMembersProvider(bgContext: bellusBackgroundContext)
        }

        if !PhotoClubHubApp.leaveEmpty {
            // load test member(s) of Fotogroep De Gender
            let genderBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
            genderBackgroundContext.name = "FG de Gender"
            genderBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            genderBackgroundContext.automaticallyMergesChangesFromParent = true
            _ = FotogroepDeGenderMembersProvider(bgContext: genderBackgroundContext)
        }

        if !PhotoClubHubApp.leaveEmpty {
            // load all current/former members of Fotogroep Waalre
            let waalreBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
            waalreBackgroundContext.name = "Fotogroep Waalre"
            waalreBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            waalreBackgroundContext.automaticallyMergesChangesFromParent = true
            _ = FotogroepWaalreMembersProvider(bgContext: waalreBackgroundContext)
        }

//        if !PhotoClubHubApp.leaveEmpty {
            // load all current members of Fotogroep Anders
            let andersBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
            andersBackgroundContext.name = "FG Anders"
            andersBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            andersBackgroundContext.automaticallyMergesChangesFromParent = true
            _ = AndersMembersProvider(bgContext: andersBackgroundContext)
//        }

    }

    // returns true if successful
    @MainActor
    static func deleteAllCoreDataObjects() {
        let forcedClearing = "Forced clearing of CoreData data for app version 2.6.2"

        // order is important because of non-optional relationships
        do {
            try deleteEntitiesOfOneType("LocalizedRemark")
            try deleteEntitiesOfOneType("Language")

            try deleteEntitiesOfOneType("MemberPortfolio")
            try deleteEntitiesOfOneType("Organization")
            try deleteEntitiesOfOneType("Photographer")

            try deleteEntitiesOfOneType("OrganizationType")
            print(forcedClearing + " successful.")
            if !leaveEmpty {
                UserDefaults.standard.set(true, forKey: resetKey)
            } else {
                UserDefaults.standard.removeObject(forKey: resetKey)
            }
        } catch {
            print(forcedClearing + " successful.")
        }
    }

}

// returns true if successful
@MainActor
func deleteEntitiesOfOneType(_ entity: String) throws {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
    fetchRequest.returnsObjectsAsFaults = false
    do {
        let viewContext = PersistenceController.shared.container.viewContext // requires @MainActor
        let results = try viewContext.fetch(fetchRequest)
        for object in results {
            guard let objectData = object as? NSManagedObject else {continue}
            viewContext.delete(objectData)
        }
        try viewContext.save()
        if entity == "OrganizationType" {
            OrganizationType.initConstants() // insert contant records into OrganizationType table if needed
        }

    } catch let error { // if `entity` identifier is not found, `try` doesn't throw. Maybe a rethrow is missing.
        print("Delete all data in \(entity) error :", error)
        throw error
    }
}
