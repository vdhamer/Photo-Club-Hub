//
//  PhotoClubHubApp.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 20/06/2021.
//

import SwiftUI
import CoreData // for NSManagedObjectContext

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
        if Settings.manualDataLoading || Settings.dataResetPending273 {
            Model.deleteAllCoreDataObjects(context: viewContext) // keep resetting if manualDataLoading=true
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

        // load list of keywords and languages from root.Level0.json file
        let level0BackgroundContext = PersistenceController.shared.container.newBackgroundContext()
        level0BackgroundContext.name = "Level 0 loader"
        level0BackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        level0BackgroundContext.automaticallyMergesChangesFromParent = true // to push ObjectTypes to bgContext?
        _ = Level0JsonReader(bgContext: level0BackgroundContext, // read root.Level0.json file
                             useOnlyFile: false)

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

        // load all current/former members of Fotoclub Bellus Imago
        let bellusBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
        bellusBackgroundContext.name = "Fotoclub Bellus Imago"
        bellusBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bellusBackgroundContext.automaticallyMergesChangesFromParent = true
        _ = FotoclubBellusImagoMembersProvider(bgContext: bellusBackgroundContext)

        // load current/former members of Fotoclub Ericamera
        let ericameraBackgroundContext = makeBgContext(ctxName: "Level 2 loader fcEricamera")
        _ = FotoclubEricameraMembersProvider(bgContext: ericameraBackgroundContext, useOnlyInBundleFile: false)

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
//            _ = XampleMaxMembersProvider(bgContext: xampleMaxBackgroundContext) // TODO uncomment

        }

        // load current/former members of Fotogroep Oirschot
         let oirschotBackgroundContext = makeBgContext(ctxName: "Level 2 loader fgOirschot")
         _ = FotogroepOirschotMembersProvider(bgContext: oirschotBackgroundContext,
                                             useOnlyInBundleFile: false)

    }

    static func makeBgContext(ctxName: String) -> NSManagedObjectContext {

        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = ctxName
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true // to push ObjectTypes to bgContext?
        return bgContext

    }
}
