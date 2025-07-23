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

    init() {

        // Core Data settings
        let persistenceController = PersistenceController.shared // for Core Data
        let viewContext = persistenceController.container.viewContext // "associated with the main application queue"
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.undoManager = nil // nil by default on iOS
        viewContext.shouldDeleteInaccessibleFaults = true

        // update version number shown in iOS Settings
        UserDefaults.standard.set(Bundle.main.fullVersion, forKey: "version_preference")
        if Settings.manualDataLoading || Settings.dataResetPending282b4646 {
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

        // load list of Expertises and Languages from root.Level0.json file
        let level0BackgroundContext = makeBgContext(ctxName: "Level 0 loader")
        _ = Level0JsonReader(bgContext: level0BackgroundContext, isInTestBundle: false, useOnlyInBundleFile: false)

        // load list of photo clubs and museums from root.Level1.json file
        let level1BackgroundContext = makeBgContext(ctxName: "Level 1 loader")
        _ = Level1JsonReader(bgContext: level1BackgroundContext, // read root.Level1.json file
                             isInTestBundle: false, useOnlyInBundleFile: false)

        // load current/former members of Fotogroep De Gender
        let genderBackgroundContext = makeBgContext(ctxName: "Level 2 loader fgDeGender")
        _ = FotogroepDeGenderMembersProvider(bgContext: genderBackgroundContext,
                                             useOnlyInBundleFile: false)

        // load current/former members of Fotogroep Waalre
        let waalreBackgroundContext = makeBgContext(ctxName: "Level 2 loader fgWaalre")
        _ = FotogroepWaalreMembersProvider(bgContext: waalreBackgroundContext,
                                           useOnlyInBundleFile: false)

        // load current/former members of Fotoclub Bellus Imago
        let bellusBackgroundContext = makeBgContext(ctxName: "Level 2 loader fcBellusImago")
        _ = FotoclubBellusImagoMembersProvider(bgContext: bellusBackgroundContext,
                                               useOnlyInBundleFile: false)

        // load current/former members of Fotogroep Oirschot
        let oirschotBackgroundContext = makeBgContext(ctxName: "Level 2 loader fgOirschot")
        _ = FotogroepOirschotMembersProvider(bgContext: oirschotBackgroundContext,
                                             useOnlyInBundleFile: false)

        if Settings.loadTestClubs {

            // load test member(s) of XampleMin. Club is called XampleMin (rather than ExampleMin) to be at end of list
            let xampleMinBackgroundContext = makeBgContext(ctxName: "Level 2 loader XampleMin")
            _ = XampleMinMembersProvider(bgContext: xampleMinBackgroundContext, useOnlyInBundleFile: false)

            // load test member(s) of XampleMax. Club is called XampleMax (rather than ExampleMax) to be at end of list
            let xampleMaxBackgroundContext = makeBgContext(ctxName: "Level 2 loader XampleMax")
            _ = XampleMaxMembersProvider(bgContext: xampleMaxBackgroundContext, useOnlyInBundleFile: false)

        }

        // load current/former members of container for Individual members of Fotobond (in region 16)
        let individueelBOBackgroundContext = makeBgContext(ctxName: "Level 2 loader IndividueelBO")
        _ = IndividueelBOMembersProvider(bgContext: individueelBOBackgroundContext, useOnlyInBundleFile: false)

        // load current/former members of Fotoclub Ericamera
        let ericameraBackgroundContext = makeBgContext(ctxName: "Level 2 loader fcEricamera")
        _ = FotoclubEricameraMembersProvider(bgContext: ericameraBackgroundContext, useOnlyInBundleFile: false)

        // load current/former members of Fotoclub Den Dungen
        let dungenBackgroundContext = makeBgContext(ctxName: "Level 2 loader fcDenDungen")
        _ = FotoclubDenDungenMembersProvider(bgContext: dungenBackgroundContext, useOnlyInBundleFile: false)

    }

    static func makeBgContext(ctxName: String) -> NSManagedObjectContext {

        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = ctxName
        bgContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        bgContext.automaticallyMergesChangesFromParent = true // to push ObjectTypes to bgContext?
        return bgContext

    }
}
