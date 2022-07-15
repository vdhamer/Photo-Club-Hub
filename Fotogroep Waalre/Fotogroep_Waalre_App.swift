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
    @StateObject var deviceOwner = DeviceOwner()

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

    var body: some Scene {
        WindowGroup {
            if deviceOwner.fullOwnerName.contains("Bram") || deviceOwner.fullOwnerName.contains("Berge") {
                MemberListView() // Bram hates the intro animation, so avoid it for him
                    .environmentObject(deviceOwner)
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext) // main Q!
                    .onAppear {
                        //      _ = BIMembersProvider()
                        _ = FGWMembersProvider(fullOwnerName: deviceOwner.fullOwnerName)
                        //      _ = TestMembersProvider()
                    }
            } else {
                AnimatedLogo() // fullOwnerName passed down to MemberListView()
                    .environmentObject(deviceOwner)
                    .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext) // main Q!
                    .onAppear {
                        //      _ = BIMembersProvider()
                        _ = FGWMembersProvider(fullOwnerName: deviceOwner.fullOwnerName)
                        //      _ = TestMembersProvider()
                    }
            }
        }
        .onChange(of: scenePhase) { _ in
            PersistenceController.shared.save() // when app moves to background
        }
    }

}

final class DeviceOwner: ObservableObject {
    @Published var fullOwnerName: String

    init() {
        fullOwnerName = DeviceOwnership().fullOwnerName
    }
}
