//
//  PhotoClubHubApp.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 20/06/2021.
//

import CoreData // for NSMergePolicy
import TipKit   // for Tips.configure
import Photo_Club_Hub_Data // for many data-related functions

@main
struct PhotoClubHubApp: App {

    @Environment(\.scenePhase) var scenePhase

    init() {

        // Skip heavy app init when running under Xcode Previews to keep #Preview rendering alive.
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return
        }

        // Automated screenshot functionality: stale-marker cleanup and handle -suppressTips CLI argument.
        ScreenshotReadiness.configureAtStartup()

        // Load persisted UI tip state (e.g. TabNavigationTip); without this call no tips are shown.
        // try? Tips.resetDatastore() /* used during manual testing only */
        try? Tips.configure([.displayFrequency(.daily)]) // show at most one tip per day

        // Core Data settings
        let persistenceController = PersistenceController.shared // for Core Data
        let viewContext = persistenceController.container.viewContext // "associated with the main application queue"
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.undoManager = nil // nil by default on iOS
        viewContext.shouldDeleteInaccessibleFaults = true

        // update version numbers shown in iOS Settings
        UserDefaults.standard.set(Bundle.main.fullVersion, forKey: "version_preference")
        let noStamp = String(localized: "?",
                             table: "PhotoClubHub.SwiftUI",
                             comment: "Stands in for an absent build date or commit")
        // "N/A" rather than "?" for the library commit: a local checkout or an unreadable pin means
        // there is no commit to name, which is a different thing from a stamp having gone missing.
        let notApplicable = String(localized: "N/A",
                                   table: "PhotoClubHub.SwiftUI",
                                   comment: "Stands in for the library commit when there is none to show")
        UserDefaults.standard.set(Bundle.main.buildDate ?? noStamp, forKey: "buildDate_preference")
        UserDefaults.standard.set(Bundle.main.gitCommit ?? noStamp, forKey: "gitCommit_preference")
        UserDefaults.standard.set(Bundle.main.libraryVersion ?? noStamp, forKey: "libraryVersion_preference")
        UserDefaults.standard.set(Bundle.main.libraryCommit ?? notApplicable, forKey: "libraryCommit_preference")
        UserDefaults.standard.set(Bundle.main.libraryCommitDate ?? notApplicable,
                                  forKey: "libraryCommitDate_preference")
        if Settings.manualDataLoading || Settings.dataResetPending {
            Model.deleteCoreDataObjects(viewContext: viewContext, deletionScope: .all)
        } else { // initialize some constant records for Language and OrganizationType (for stability)
            Language.initConstants(context: viewContext)
            OrganizationType.initConstants(context: viewContext)
        }

    }

    var body: some Scene {
        WindowGroup {
            RootView() // replaced the old inline #unavailable(iOS 26) PreludeView fork; see RootView.swift
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
        .onChange(of: scenePhase) { // zero-param closure is the iOS 17+ form; pre-iOS 17 the closure took (newValue)
            PersistenceController.shared.save() // Core Data will not automatically save on when scene -> background
        }
    }

}
