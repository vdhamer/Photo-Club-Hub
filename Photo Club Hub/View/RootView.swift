//
//  RootView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 05/07/2026.
//

import SwiftUI

struct RootView: View {

    @State private var showPrelude = true

    private var isRunningTests: Bool {
        ProcessInfo.processInfo.environment["IS_RUNNING_TESTS"] == "1"
    }

    var body: some View {
        if showPrelude {
            preludeView
                .onAppear {
                    if !Settings.manualDataLoading && !isRunningTests {
                        PhotoClubHubApp.loadClubsAndMembers()
                    }
                }
        } else {
            MainTabView()
        }
    }

    @ViewBuilder
    private var preludeView: some View {
        if #unavailable(iOS 26) {
            PreludeView1718(onFinished: finish)
        } else {
            PreludeView2627(onFinished: finish)
        }
    }

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
