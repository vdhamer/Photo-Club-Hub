//
//  PhotoClubHubApp.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 20/06/2021.
//

import SwiftUI
import CoreData // for ManagedObjectContext

@main
struct FotogroepWaalreApp: App {

    @Environment(\.scenePhase) var scenePhase

    init() {
        // Core Data settings
        let persistenceController = PersistenceController.shared // for Core Data
        let viewContext = persistenceController.container.viewContext // "associated with the main application queue"
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.undoManager = nil // nil by default on iOS
        viewContext.shouldDeleteInaccessibleFaults = true

        // update version number shown in iOS Settings app
        UserDefaults.standard.set(Bundle.main.fullVersion, forKey: "version_preference")
    }

    var body: some Scene {
        WindowGroup {
            PreludeView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext) // main queue!
                .onAppear {

                    // load test member(s) of Fotogroep Bellus Imago TODO remove
                   let biBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                    biBackgroundContext.name = "Bellus Imago refresh"
                    biBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                    _ = BellusImagoMembersProvider(bgContext: biBackgroundContext)

                    // load test member(s) of Fotogroep De Gender TODO remove
                    let dgBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                    dgBackgroundContext.name = "De Gender refresh"
                    dgBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                    _ = FotogroepDeGenderMembersProvider(bgContext: dgBackgroundContext)

                    // load all current members of Fotogroep Anders TODO remove
                    let andersBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                    andersBackgroundContext.name = "Anders refresh"
                    andersBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                    _ = AndersMembersProvider(bgContext: andersBackgroundContext)

                    // load all current/former members of Fotogroep Waalre
                    let fgwBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                    fgwBackgroundContext.name = "Fotogroep Waalre"
                    fgwBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                    _ = FotogroepWaalreMembersProvider(bgContext: fgwBackgroundContext)

                    // Load a few test members for 3 non-existent photo clubs.
                    // But this also tests support for clubs with same name in different towns
                    let taBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                    taBackgroundContext.name = "Amsterdam"
                    taBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                    _ = TestClubAmsterdamMembersProvider(bgContext: taBackgroundContext)

                    let tdBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                    tdBackgroundContext.name = "Den Haag"
                    tdBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                    _ = TestClubDenHaagMembersProvider(bgContext: tdBackgroundContext)

                    let trBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                    trBackgroundContext.name = "Rotterdam"
                    trBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                    _ = TestClubRotterdamMembersProvider(bgContext: trBackgroundContext)

                    // More groups can be added here like BIMembersProvider()
                    // They can so be loaded manually using pull-to-refresh on the Photo Clubs screen.
                }
        }
        .onChange(of: scenePhase) { // pre-iOS 17 there was 1 param. Since iOS 17 it is 0 or 2.
            PersistenceController.shared.save() // when app moves to background
        }
    }

}
