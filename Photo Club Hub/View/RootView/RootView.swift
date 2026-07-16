//
//  RootView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 05/07/2026.
//

import SwiftUI
import CoreData // for NSManagedObjectContext

// RootView is the app's single WindowGroup root and is activated in PhotoClubHubApp.swift.
// MainTabView is the permanent root content; PreludeView is layered on top until the user dismisses it.
// A ZStack (rather than .fullScreenCover) is used so the PreludeView is part of the very first rendered
// frame — a fullScreenCover is a presentation transaction, which briefly exposes the view behind it at launch.
struct RootView: View {

    // The `-skipPrelude YES` launch argument starts the app on the main tabs without the splash.
    // Used by the screenshot pipeline (#775/#776); normal launches never pass it, so it stays true.
    @State private var showPrelude = !UserDefaults.standard.bool(forKey: "skipPrelude")

    // Read the managed object context from the environment so it can be explicitly re-passed to MainTabView.
    // Re-passing is required because SwiftUI previews don't always propagate environment values reliably
    // through intermediate view boundaries — explicit injection guarantees Core Data used it for @FetchRequests.
    @Environment(\.managedObjectContext) private var viewContext

    // True while the unit-test bundle is running. Set via IS_RUNNING_TESTS in Photo Club Hub.xctestplan.
    // Used to skip the production auto-load so tests don't race the app loader into PersistenceController.shared.
    // This is a self-defined signal, so it works for Swift Testing, XCTest, and `swift test` alike (see issue #756).
    private var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["IS_RUNNING_TESTS"] == "1"
    }

    // True when rendering inside an Xcode #Preview. loadClubsAndMembers() must not run there:
    // it uses PersistenceController.shared while previews inject PersistenceController.preview,
    // and loading the Core Data model twice makes entity resolution ambiguous (@FetchRequest crashes
    // with "A fetch request must have an entity"). PhotoClubHubApp.init has the same guard.
    private var isRunningInPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var body: some View {
        ZStack {
            MainTabView()
                .environment(\.managedObjectContext, viewContext)
            preludeView
                // animated in finish(); .transition(.opacity) doesn't work because...
                // ...PreludeView uses .compositingGroup(), a separate render layer
                .opacity(showPrelude ? 1 : 0)
                .allowsHitTesting(showPrelude) // stop reacting to taps and gestures
        }
        .onAppear {
            if !Settings.manualDataLoading && !isRunningTests && !isRunningInPreviews {
                PhotoClubHubApp.loadClubsAndMembers()
                print("Loading clubs and members in background")
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
        withAnimation(.spring(duration: 0.6)) {
            showPrelude = false
        }
    }

}

// MARK: - Preview

// Believe it or not, this preview works.

#Preview {
    RootView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
