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
        if Settings.manualDataLoading || Settings.dataResetPending {
            Model.deleteAllCoreDataObjects(viewContext: viewContext) // keep resetting if manualDataLoading=true
        } else { // initialize some constant records for Language and OrganizationType (for stability)
            Language.initConstants(context: viewContext)
            OrganizationType.initConstants(context: viewContext)
        }

    }

    var body: some Scene {
        WindowGroup {
            // Here we switch between the pre-Liquid Glass view versions and post-Liquid Glass view versions
            if #unavailable(iOS 26.0) { // iOS 17.6 ...  (mandated by app min requirement) or 18
                PreludeView1718()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .onAppear {
                        if !Settings.manualDataLoading {
                            PhotoClubHubApp.loadClubsAndMembers()
                        }
                    }
            } else {
                PreludeView2626()
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                    .onAppear {
                        if !Settings.manualDataLoading {
                            PhotoClubHubApp.loadClubsAndMembers()
                        }
                    }
            }
        }
        .onChange(of: scenePhase) { // pre-iOS 17 there was 1 param. Since iOS 17 it is 0 or 2.
            PersistenceController.shared.save() // persist data when app moves to background (may not be needed)
        }
    }

}

extension PhotoClubHubApp {

    // swiftlint:disable:next function_body_length
    static func loadClubsAndMembers() {

        let isBeingTested = false // these are being loaded to get the data into Core Data, not for testing purposes
        let useOnlyInBundleFile = false

        // MARK: - Level 0

        // load list of Expertises and Languages from root.Level0.json file
        let level0BackgroundContext = makeBgContext(ctxName: "Level 0 loader")
        _ = Level0JsonReader(bgContext: level0BackgroundContext,
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: useOnlyInBundleFile)

        // MARK: - Level 1

        // load list of photo clubs and museums from root.Level1.json file
        let level1BackgroundContext = makeBgContext(ctxName: "Level 1 loader")
        _ = Level1JsonReader(bgContext: level1BackgroundContext, // read root.Level1.json file
                             isBeingTested: isBeingTested,
                             useOnlyInBundleFile: useOnlyInBundleFile)

        // MARK: - Level 2

        // load current/former members of Fotogroep De Gender
        let genderBackgroundContext = makeBgContext(ctxName: "Level 2 loader fgDeGender")
        _ = FotogroepDeGenderMembersProvider(bgContext: genderBackgroundContext,
                                             isBeingTested: isBeingTested,
                                             useOnlyInBundleFile: useOnlyInBundleFile)

        // load current/former members of Fotogroep Waalre
        let waalreBackgroundContext = makeBgContext(ctxName: "Level 2 loader fgWaalre")
        _ = FotogroepWaalreMembersProvider(bgContext: waalreBackgroundContext,
                                           isBeingTested: isBeingTested,
                                           useOnlyInBundleFile: useOnlyInBundleFile)

        // load current/former members of Fotoclub Bellus Imago
        let bellusBackgroundContext = makeBgContext(ctxName: "Level 2 loader fcBellusImago")
        _ = FotoclubBellusImagoMembersProvider(bgContext: bellusBackgroundContext,
                                               isBeingTested: isBeingTested,
                                               useOnlyInBundleFile: useOnlyInBundleFile)

        // load current/former members of Fotogroep Oirschot
        let oirschotBackgroundContext = makeBgContext(ctxName: "Level 2 loader fgOirschot")
        _ = FotogroepOirschotMembersProvider(bgContext: oirschotBackgroundContext,
                                             isBeingTested: isBeingTested,
                                             useOnlyInBundleFile: useOnlyInBundleFile)

        if Settings.loadTestClubs {

            // load test member(s) of XampleMin. Club name starts with an X in order to be at end of list
            let xampleMinBackgroundContext = makeBgContext(ctxName: "Level 2 loader XampleMin")
            _ = XampleMinMembersProvider(bgContext: xampleMinBackgroundContext,
                                         isBeingTested: isBeingTested,
                                         useOnlyInBundleFile: useOnlyInBundleFile)

            // load test member(s) of XampleMax. Club name starts with an X in order to be at end of list
            let xampleMaxBackgroundContext = makeBgContext(ctxName: "Level 2 loader XampleMax")
            _ = XampleMaxMembersProvider(bgContext: xampleMaxBackgroundContext,
                                         isBeingTested: isBeingTested,
                                         useOnlyInBundleFile: useOnlyInBundleFile)

        }

        // load current/former members of container for Individual members of Fotobond (in region 16)
        let individueelBOBackgroundContext = makeBgContext(ctxName: "Level 2 loader IndividueelBO")
        _ = IndividueelBOMembersProvider(bgContext: individueelBOBackgroundContext,
                                         isBeingTested: isBeingTested,
                                         useOnlyInBundleFile: useOnlyInBundleFile)

        // load current/former members of Fotoclub Ericamera
        let ericameraBackgroundContext = makeBgContext(ctxName: "Level 2 loader fcEricamera")
        _ = FotoclubEricameraMembersProvider(bgContext: ericameraBackgroundContext,
                                             isBeingTested: isBeingTested,
                                             useOnlyInBundleFile: useOnlyInBundleFile)

        // load current/former members of Fotoclub Den Dungen
        let dungenBackgroundContext = makeBgContext(ctxName: "Level 2 loader fcDenDungen")
        _ = FotoclubDenDungenMembersProvider(bgContext: dungenBackgroundContext,
                                             isBeingTested: isBeingTested,
                                             useOnlyInBundleFile: useOnlyInBundleFile)

        // load current/former members of Fotokring Sint-Michielsgestel
        let gestelBackgroundContext = makeBgContext(ctxName: "Level 2 loader fkGestel")
        _ = FotokringStMichielsgestelMembersProvider(bgContext: gestelBackgroundContext,
                                                     isBeingTested: isBeingTested,
                                                     useOnlyInBundleFile: useOnlyInBundleFile)
    }

    static func makeBgContext(ctxName: String) -> NSManagedObjectContext {

        let bgContext = PersistenceController.shared.container.newBackgroundContext()
        bgContext.name = ctxName
        if isDebug && Settings.errorOnCoreDataMerge {
            bgContext.mergePolicy = NSMergePolicy.error // to force detection of Core Data merge issues
        } else {
            bgContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump // is .mergeByPropertyObjectTrump better?
        }
        bgContext.automaticallyMergesChangesFromParent = true // to push ObjectTypes to bgContext?
        bgContext.undoManager = nil // no undo manager (for speed)
        return bgContext

    }
}
