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

    init() {
        // Core Data settings
        let persistenceController = PersistenceController.shared // for Core Data
        let viewContext = persistenceController.container.viewContext // "associated with the main application queue"
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.undoManager = nil // nil by default on iOS
        viewContext.shouldDeleteInaccessibleFaults = true

        OrganizationType.initConstants() // insert contant records into OrganizationType table if needed

        // update version number shown in iOS Settings
        UserDefaults.standard.set(Bundle.main.fullVersion, forKey: "version_preference")
    }

    var body: some Scene {
        WindowGroup {
            PreludeView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext) // main queue!
                .onAppear {
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

        // load list of photo clubs and museums from root.Level1.json file
        let level1BackgroundContext = PersistenceController.shared.container.newBackgroundContext()
        level1BackgroundContext.name = "root.level1.json"
        level1BackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        level1BackgroundContext.automaticallyMergesChangesFromParent = true // needed to push ObjectTypes down to bgContext?
        _ = RootLevel1JsonReader(bgContext: level1BackgroundContext, useOnlyFile: false) // read root.Level1.json file

        // warning: following clubs rely on Level 1 file for GPS coordiantes

        // load test member(s) of Fotogroep Bellus Imago
        let bellusBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
        bellusBackgroundContext.name = "Bellus Imago"
        bellusBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bellusBackgroundContext.automaticallyMergesChangesFromParent = true
        _ = BellusImagoMembersProvider(bgContext: bellusBackgroundContext)

        // load test member(s) of Fotogroep De Gender
        let genderBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
        genderBackgroundContext.name = "FG de Gender"
        genderBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        genderBackgroundContext.automaticallyMergesChangesFromParent = true
        _ = FotogroepDeGenderMembersProvider(bgContext: genderBackgroundContext)

        // load all current members of Fotogroep Anders
        let andersBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
        andersBackgroundContext.name = "FG Anders"
        andersBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        andersBackgroundContext.automaticallyMergesChangesFromParent = true
        _ = AndersMembersProvider(bgContext: andersBackgroundContext)

        // load all current/former members of Fotogroep Waalre
        let waalreBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
        waalreBackgroundContext.name = "Fotogroep Waalre"
        waalreBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        waalreBackgroundContext.automaticallyMergesChangesFromParent = true
        _ = FotogroepWaalreMembersProvider(bgContext: waalreBackgroundContext)

    }

}
