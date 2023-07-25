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
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        viewContext.undoManager = nil // nil by default on iOS
        viewContext.shouldDeleteInaccessibleFaults = true

        // update version number shown in iOS Settings app
        UserDefaults.standard.set(Bundle.main.fullVersion, forKey: "version_preference")
    }

    static var antiZombiePinningOfMemberPortfolios: Set<MemberPortfolio> = [] // hack to avoid zombies, global scope

    var body: some Scene {
        WindowGroup {
            PreludeView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext) // main queue!
                .onAppear {
                    // load current/former members of Fotogroep Waalre
//                    let fgwBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
//                    _ = FGWMembersProvider(bgContext: fgwBackgroundContext)

                    // Load a few test members for 3 non-existent photo clubs.
                    // This demos multi-club support.
                    // But this also tests support for clubs with same name in different towns
                    let taBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                    _ = TestClubAmsterdamMembersProvider(bgContext: taBackgroundContext)

                    let tdBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                    _ = TestClubDenHaagMembersProvider(bgContext: tdBackgroundContext)

                    let trBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                    _ = TestClubRotterdamMembersProvider(bgContext: trBackgroundContext)

                    let biBackgroundContext = PersistenceController.shared.container.newBackgroundContext()
                    _ = BIMembersProvider(bgContext: biBackgroundContext)

                    // More groups can be added here like BIMembersProvider()
                    // They can so be loaded manually using pull-to-refresh on the Photo Clubs screen.
                }
        }
        .onChange(of: scenePhase) { _ in
            PersistenceController.shared.save() // when app moves to background
        }
    }

}
