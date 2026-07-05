//
//  RootView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 05/07/2026.
//

import SwiftUI
import CoreData // for NSManagedObjectContext

// RootView is the app's single WindowGroup root.
// MainTabView is always the permanent root content; PreludeView is presented as a full-screen cover on top.
struct RootView: View {

    @State private var showPrelude = true

    // Read the managed object context from the environment so it can be explicitly re-passed to MainTabView.
    // Re-passing is required because SwiftUI previews don't always propagate environment values reliably
    // through intermediate view boundaries — explicit injection guarantees Core Data reaches @FetchRequest views.
    @Environment(\.managedObjectContext) private var viewContext

    // True while the unit-test bundle is running. Set via IS_RUNNING_TESTS in Photo Club Hub.xctestplan.
    // Used to skip the production auto-load so tests don't race the app loader into PersistenceController.shared.
    // This is a self-defined signal, so it works for Swift Testing, XCTest, and `swift test` alike (see issue #756).
    private var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["IS_RUNNING_TESTS"] == "1"
    }

    var body: some View {
        MainTabView()
            .environment(\.managedObjectContext, viewContext)
            // PreludeView is a full-screen cover so MainTabView is always in the hierarchy and its
            // environment (Core Data context, @FetchRequests) is fully set up before the cover is shown.
            .fullScreenCover(isPresented: $showPrelude) {
                preludeView
            }
            .onAppear {
                if !Settings.manualDataLoading && !isRunningTests {
                    PhotoClubHubApp.loadClubsAndMembers()
                    print("Loading clubs and members")
                }
            }
    }

    // Separate @ViewBuilder property so body stays readable despite the #unavailable availability check.
    @ViewBuilder
    private var preludeView: some View {
        if #unavailable(iOS 26) {
            PreludeView1718(onFinished: finish)
        } else {
            PreludeView2627(onFinished: finish)
        }
    }

    // Called by the active PreludeView when the user exits the splash screen.
    private func finish() {
        showPrelude = false
    }

}

#Preview {
    RootView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
