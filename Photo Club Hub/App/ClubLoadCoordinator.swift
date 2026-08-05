//
//  ClubLoadCoordinator.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 03/08/2026.
//

import CoreData // for NSManagedObjectContext
import Photo_Club_Hub_Data // for Model

/// Serializes load passes so pull-to-refresh never races an in-flight startup load pass or another refresh.
/// Enforces the ordering: drain everything ahead of us → delete → fresh load.
@MainActor
final class ClubLoadCoordinator {
    static let shared = ClubLoadCoordinator()

    /// Tail of the chain of load passes. Never reset to nil: a finished Task is a satisfied
    /// `await`, so chaining onto a completed one costs nothing and keeps the ordering rule simple.
    private var currentLoad: Task<Void, Never>?

    /// Whether the startup pass has been requested. Separate from `currentLoad` because that no
    /// longer distinguishes "running" from "finished", and `.onAppear` can fire more than once.
    private var hasStartedInitialLoadPass = false

    /// Startup path: start the first load pass; stays fire-and-forget for the caller.
    func loadIfIdle() {
        guard currentLoad == nil else { return }
        currentLoad = Task {
            await PhotoClubHubApp.loadClubsAndMembers()
            self.currentLoad = nil
        }
    }

    /// Pull-to-refresh: drain any in-flight generation, delete, then run and await a fresh one.
    func refresh(viewContext: NSManagedObjectContext) async {
        _ = Settings.dataResetPending            // side-effect clears the flag
        await currentLoad?.value                 // drain prior generation
        Model.deleteCoreDataObjects(viewContext: viewContext, deletionScope: .all)
        let task = Task { await PhotoClubHubApp.loadClubsAndMembers() }
        currentLoad = task
        await task.value                         // keep refresh spinner until reload completes
        currentLoad = nil
    }
}
