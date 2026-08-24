//
//  ClubLoadCoordinator.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 03/08/2026.
//

import CoreData // for NSManagedObjectContext
import Observation // for @Observable
import Photo_Club_Hub_Data // for Model, LevelLoader and Settings

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
/// joins the club loaders, live in `LevelLoader.loadAllLevels()` in the Photo Club Hub Data package and exist
/// for an unrelated reason (a Core Data uniqueness constraint on `Expertise`). Two different orderings, no
/// shared mechanism — reading them as one topic is what makes this area feel harder than it is.
/// That `loadAllLevels` returns only once every club loader has finished is what `enqueue` depends on: a
/// queued refresh must not delete Core Data on top of a pass that is still writing (#802).
///
/// **`passesInFlight` is a second view of that same queue, not a second queue.**
/// The queue itself cannot be counted (there is no list),
/// so the counter is kept alongside it purely so views can ask "is data on its /// way?".
/// The Clubs list used to answer that question by guessing from an empty fetch result, and guessed
/// wrong during the delete-then-reload window (#821).
/// It is maintained in `enqueue` only, and would go away with the last caller of `isLoadingOrPending`.
@MainActor
@Observable
final class ClubLoadCoordinator {
    static let shared = ClubLoadCoordinator()

    /// Tail of the queue of load passes. Never reset to nil: a finished Task is a satisfied
    /// `await`, so queueing behind a completed one costs nothing and keeps the ordering rule simple.
    private var currentLoad: Task<Void, Never>? // `Never` is about error handling

    /// Whether the startup pass has been requested. Separate from `currentLoad` because that no
    /// longer distinguishes "running" from "finished", and `.onAppear` can fire more than once.
    private(set) var hasStartedInitialLoadPass = false

    /// How many load passes have been requested and not yet finished.
    /// Counts a pass from the moment it is queued, not from the moment it starts running:
    /// a requrested screen refresh that is waiting behind a startup pass is
    /// already a reason not to explain an empty screen away as over-filtering.
    private(set) var passesInFlight = 0

    /// Whether the pass currently queued or running is the startup one. Only the startup pass lacks a
    /// spinner of its own, so it is the only one a view should replace an empty list with a `ProgressView`
    /// for; pull-to-refresh already draws one.
    private(set) var startupPassInFlight = false

    /// Whether data is on its way, so an empty list is not something to explain to the user.
    ///
    /// Also true in the window before `RootView.onAppear` has called `loadIfIdle()`: nothing has been
    /// requested yet, but something is about to be. The exception is manual-loading mode, where no startup
    /// pass is automatically requested and an empty database is the honest end-state rather than a transient one.
    ///
    /// Caveat: `RootView` also skips `loadIfIdle()` while running tests or Xcode previews, where this
    /// therefore stays true for the whole run and empty-list hints never appear. Harmless — the preview
    /// store has members and no test asserts on those strings — but it is not a bug when spotted.
    var isLoadingOrPending: Bool {
        passesInFlight > 0 || (!hasStartedInitialLoadPass && !Settings.manualDataLoading)
    }

    /// The subset of `isLoadingOrPending` that is the initial data loading rather than a pull-to-refresh.
    var isPerformingStartupLoad: Bool {
        startupPassInFlight || (!hasStartedInitialLoadPass && !Settings.manualDataLoading)
    }

    /// Startup path: start the first load pass; stays fire-and-forget for the caller.
    func loadIfIdle() {
        guard !hasStartedInitialLoadPass else { return }
        hasStartedInitialLoadPass = true
        enqueue(isStartupPass: true) { await LevelLoader.loadAllLevels() }
    }

    /// Pull-to-refresh: queue a delete-then-reload behind whatever is already in flight, and await it
    /// so the refresh spinner stays up until the new data is in.
    func refresh(viewContext: NSManagedObjectContext) async {
        _ = Settings.dataResetPending            // side-effect clears the flag
        await enqueue(isStartupPass: false) {
            Model.deleteCoreDataObjects(viewContext: viewContext, deletionScope: .all)
            await LevelLoader.loadAllLevels()
        }.value
    } // SwiftUI's refresh spinner automatically stops here

    /// Appends `work` to the queue of load passes, and returns its Task.
    ///
    /// The point of doing it this way is that `currentLoad` is replaced *synchronously*, with no
    /// suspension between reading the predecessor and storing the successor. Draining inside `refresh`
    /// instead (`await currentLoad?.value` and then deleting) let two overlapping refreshes clear the
    /// same gate: both waited on the same pass, and the second one went on to delete Core Data
    /// on top of the first one's in-flight reload — the very race #802 set out to remove.
    /// The counter is bumped here rather than inside the `Task` for the same reason `currentLoad` is
    /// replaced here: both must happen before the first suspension point, so that a pass counts as
    /// pending from the instant it is requested.
    @discardableResult
    private func enqueue(isStartupPass: Bool,
                         _ work: @escaping @MainActor () async -> Void) -> Task<Void, Never> {
        let previous = currentLoad
        passesInFlight += 1
        if isStartupPass { startupPassInFlight = true }
        let task = Task { @MainActor in
            defer {
                passesInFlight -= 1
                if isStartupPass { startupPassInFlight = false }
            }
            await previous?.value // everything queued ahead of us finishes first
            await work()
        }
        currentLoad = task
        return task
    }
}
