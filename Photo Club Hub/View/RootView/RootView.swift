//
//  RootView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 05/07/2026.
//

import SwiftUI // RootView is a SwiftUI view

// RootView is the app's single WindowGroup root. It owns the splash-to-tabs transition:
// show PreludeView until the user exits it, then replace it with MainTabView.
struct RootView: View {

    @State private var showPrelude = true

    // True while the unit-test bundle is running. Set via IS_RUNNING_TESTS in Photo Club Hub.xctestplan.
    // Used to skip the production auto-load so tests don't race the app loader into PersistenceController.shared.
    // This is a self-defined signal, so it works for Swift Testing, XCTest, and `swift test` alike (see issue #756).
    private var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["IS_RUNNING_TESTS"] == "1"
    }

    var body: some View {
        if showPrelude {
            preludeView
                // .onAppear is placed here (not on MainTabView) so loadClubsAndMembers() fires exactly once at launch.
                .onAppear {
                    if !Settings.manualDataLoading && !isRunningTests {
                        PhotoClubHubApp.loadClubsAndMembers()
                        print("Loading clubs and members")
                    }
                }
        } else {
            MainTabView()
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
        withAnimation {
            showPrelude = false
        }
    }

}

#Preview {
    RootView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
