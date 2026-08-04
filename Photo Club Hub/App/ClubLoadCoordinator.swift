//
//  ClubLoadCoordinator.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 03/08/2026.
//

import CoreData // for NSManagedObjectContext
import Photo_Club_Hub_Data // for Model

/// Serializes load generations so pull-to-refresh never races an in-flight startup load.
/// Enforces the ordering: drain in-flight load → delete → fresh load.
@MainActor
final class ClubLoadCoordinator {
    static let shared = ClubLoadCoordinator()
    private var currentLoad: Task<Void, Never>?

    /// Startup path: start a generation if none is running; stays fire-and-forget for the caller.
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
