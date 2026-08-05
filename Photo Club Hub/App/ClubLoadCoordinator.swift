//
//  ClubLoadCoordinator.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 03/08/2026.
//

import CoreData // for NSManagedObjectContext
import Photo_Club_Hub_Data // for Model

/// Serializes JSON load passes so pull-to-refresh never races an in-flight startup load pass or a preceding refresh.
/// Enforces the ordering: drain everything ahead of us → delete → fresh load.
///
/// **The model, in one place.** Load passes run on a queue: one at a time, in request order. Two kinds of
/// pass go onto it:
/// - *startup* — `loadIfIdle()`, at most once per launch, no delete, so it merges into whatever is there.
/// - *refresh* — `refresh(viewContext:)`, per pull, deletes **all** Core Data objects and rebuilds from
///   scratch. This is the only thing that purges records which disappeared upstream.
///
/// That asymmetry is the entire reason this class exists: a refresh's wipe must never land on a pass that
/// is still writing. Without pull-to-refresh there would be one pass per launch and no coordinator at all.
///
/// **It is a Task queue with no queue object.** Swift offers no serial async queue, and `@MainActor` is not
/// one: an actor yields its executor at every `await`, so two refreshes can interleave across suspension
/// points. The queue is therefore implicit — each new `Task` captures its predecessor and awaits it before
/// starting (see `enqueue`), while `currentLoad` holds nothing but the tail. Do not go looking for a list:
/// there isn't one, so pending passes cannot be counted, enumerated or individually cancelled. Depth is
/// normally 0 or 1, and finished passes deallocate as the queue drains.
///
/// Membership is "work that has been requested", with one deliberate exception: the tail stays put after it
/// finishes, so `enqueue` never needs a special case for an empty queue. `currentLoad != nil` therefore does
/// not mean anything is in flight — which is why `hasStartedInitialLoadPass` exists as a separate flag.
///
/// **Ordering *within* a pass is not this class's concern.** Level 0 before Level 2, and the task group that
/// joins the club loaders, live in `PhotoClubHubApp.loadLevels0To2()` and exist for an unrelated reason (a
/// Core Data uniqueness constraint on `Expertise`). Two different orderings, no shared mechanism — reading
/// them as one topic is what makes this area feel harder than it is. Yes, this comment block is by Claude Code Opus 5.
@MainActor
final class ClubLoadCoordinator {
    static let shared = ClubLoadCoordinator()

    /// Tail of the queue of load passes. Never reset to nil: a finished Task is a satisfied
    /// `await`, so queueing behind a completed one costs nothing and keeps the ordering rule simple.
    private var currentLoad: Task<Void, Never>? // `Never` is about error handling

    /// Whether the startup pass has been requested. Separate from `currentLoad` because that no
    /// longer distinguishes "running" from "finished", and `.onAppear` can fire more than once.
    private var hasStartedInitialLoadPass = false

    /// Startup path: start the first load pass; stays fire-and-forget for the caller.
    func loadIfIdle() {
        guard !hasStartedInitialLoadPass else { return }
        hasStartedInitialLoadPass = true
        enqueue { await PhotoClubHubApp.loadLevels0To2() }
    }

    /// Pull-to-refresh: queue a delete-then-reload behind whatever is already in flight, and await it
    /// so the refresh spinner stays up until the new data is in.
    func refresh(viewContext: NSManagedObjectContext) async {
        _ = Settings.dataResetPending            // side-effect clears the flag
        await enqueue {
            Model.deleteCoreDataObjects(viewContext: viewContext, deletionScope: .all)
            await PhotoClubHubApp.loadLevels0To2()
        }.value
    } // SwiftUI's refresh spinner automatically stops here

    /// Appends `work` to the queue of load passes, and returns its Task.
    ///
    /// The point of doing it this way is that `currentLoad` is replaced *synchronously*, with no
    /// suspension between reading the predecessor and storing the successor. Draining inside `refresh`
    /// instead (`await currentLoad?.value` and then deleting) let two overlapping refreshes clear the
    /// same gate: both waited on the same pass, and the second one went on to delete Core Data
    /// on top of the first one's in-flight reload — the very race #802 set out to remove.
    @discardableResult
    private func enqueue(_ work: @escaping @MainActor () async -> Void) -> Task<Void, Never> {
        let previous = currentLoad
        let task = Task { @MainActor in
            await previous?.value // everything queued ahead of us finishes first
            await work()
        }
        currentLoad = task
        return task
    }
}
