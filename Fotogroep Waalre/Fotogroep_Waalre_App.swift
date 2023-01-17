//
//  Fotogroep_WaalreApp.swift
//  Fotogroep Waalre
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

        // update version number shown in Settings
        UserDefaults.standard.set(Bundle.main.fullVersion, forKey: "version_preference")
    }

    static var antiZombiePinningOfMemberPortfolios: Set<MemberPortfolio> = [] // hack to avoid zombies, global scope

    var body: some Scene {
        WindowGroup {
            PreludeView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext) // main queue!
                .onAppear {
//                    _ = FGWMembersProvider() // always load members of Fotogroep Waalre
                    _ = TestClubMembersProvider()
                    _ = TestClub2MembersProvider()
                    // other groups can be added here by calling, for example, TestMembersProvider()
                    // but they are loaded by Pulling-to-Refresh the Photo Clubs screen
                }
        }
        .onChange(of: scenePhase) { _ in
            PersistenceController.shared.save() // when app moves to background
        }
    }

}
