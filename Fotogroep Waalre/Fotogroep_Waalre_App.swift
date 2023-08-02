//
//  Fotogroep_WaalreApp.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 20/06/2021.
//

import SwiftUI
import CoreData // for mergePolicy

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
        .onChange(of: scenePhase) { _ in
            PersistenceController.shared.save() // when app moves to background
        }
    }

}
