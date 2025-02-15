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

    @Environment(\.scenePhase) var scenePhase
    static let includeXampleClubs: Bool = true // whether or not to include XmpleMin and XmpleMax clubs

    init() {

        // Core Data settings
        let persistenceController = PersistenceController.shared // for Core Data
        let viewContext = persistenceController.container.viewContext // "associated with the main application queue"
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.undoManager = nil // nil by default on iOS
        viewContext.shouldDeleteInaccessibleFaults = true

        // update version number shown in iOS Settings
        UserDefaults.standard.set(Bundle.main.fullVersion, forKey: "version_preference")

        if Settings.manualDataLoading || Settings.dataResetPending272 {
            Model.deleteAllCoreDataObjects() // keep resetting if manualDataLoading=true
        } else { // initialize some constant records for Language and OrganizationType (for stability)
            Language.initConstants()
            OrganizationType.initConstants()
        }

    }

    var body: some Scene {
        WindowGroup {
            PreludeView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext) // main queue!
                .onAppear {
                    if !Settings.manualDataLoading {
                        PhotoClubHubApp.loadClubsAndMembers()
                    }
                }
        }
        .onChange(of: scenePhase) { // pre-iOS 17 there was 1 param. Since iOS 17 it is 0 or 2.
            PersistenceController.shared.save() // persist data when app moves to background (may not be needed)
        }
    }

}

extension PhotoClubHubApp {

    static func loadClubsAndMembers() {

        // load list of photo clubs and museums from root.Level1.json file
        let level1BackgroundContext = PersistenceController.shared.container.newBackgroundContext()
        level1BackgroundContext.name = "Level 1 loader"
        level1BackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        level1BackgroundContext.automaticallyMergesChangesFromParent = true // to push ObjectTypes to bgContext?
        _ = Level1JsonReader(bgContext: level1BackgroundContext, // read root.Level1.json file
                             useOnlyFile: false)

        // load test member(s) of Fotogroep De Gender
        let genderBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
        genderBackgroundContext.name = "FG de Gender"
        genderBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        genderBackgroundContext.automaticallyMergesChangesFromParent = true
        _ = FotogroepDeGenderMembersProvider(bgContext: genderBackgroundContext)

        // load all current/former members of Fotogroep Waalre
        let waalreBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
        waalreBackgroundContext.name = "Fotogroep Waalre"
        waalreBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        waalreBackgroundContext.automaticallyMergesChangesFromParent = true
        _ = FotogroepWaalreMembersProvider(bgContext: waalreBackgroundContext)

        if includeXampleClubs {

            // load test member(s) of XampleMin. Club is called XampleMin (rather than ExampleMin) to be at end of list
            let xampleMinBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
            xampleMinBackgroundContext.name = "XampleMin"
            xampleMinBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            xampleMinBackgroundContext.automaticallyMergesChangesFromParent = true
            _ = XampleMinMembersProvider(bgContext: xampleMinBackgroundContext)

            // load test member(s) of XampleMax. Club is called XampleMax (rather than ExampleMax) to be at end of list
            let xampleMaxBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
            xampleMaxBackgroundContext.name = "XampleMax"
            xampleMaxBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            xampleMaxBackgroundContext.automaticallyMergesChangesFromParent = true
            _ = XampleMaxMembersProvider(bgContext: xampleMaxBackgroundContext)

        }
    }

}
