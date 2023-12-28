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

        OrganizationType.initConstants() // insert contant records into OrganizationType table if needed

        // update version number shown in iOS Settings app
        UserDefaults.standard.set(Bundle.main.fullVersion, forKey: "version_preference")
    }

    var body: some Scene {
        WindowGroup {
            PreludeView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext) // main queue!
                .onAppear {

                    // load test member(s) of Fotogroep Bellus Imago TODO 4 photo clubs temp commented out
//                    let biBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
//                    biBackgroundContext.name = "Bellus Imago refresh"
//                    biBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
//                    _ = BellusImagoMembersProvider(bgContext: biBackgroundContext)

                    // load test member(s) of Fotogroep De Gender
                    let dgBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                    dgBackgroundContext.name = "De Gender refresh"
                    dgBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                    _ = FotogroepDeGenderMembersProvider(bgContext: dgBackgroundContext)

                    // load all current members of Fotogroep Anders
//                    let andersBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
//                    andersBackgroundContext.name = "Anders refresh"
//                    andersBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
//                    _ = AndersMembersProvider(bgContext: andersBackgroundContext)

                    // load all current/former members of Fotogroep Waalre
//                    let fgwBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
//                    fgwBackgroundContext.name = "Fotogroep Waalre"
//                    fgwBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
//                    _ = FotogroepWaalreMembersProvider(bgContext: fgwBackgroundContext)

                    // load list of photo clubs from OrganizationList.json file
                    let olBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                    olBackgroundContext.name = "ClubList"
                    olBackgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
                    _ = OrganizationList(bgContext: olBackgroundContext) // read OrganizationList.json file
                }
        }
        .onChange(of: scenePhase) { // pre-iOS 17 there was 1 param. Since iOS 17 it is 0 or 2.
            PersistenceController.shared.save() // when app moves to background
        }
    }

}
