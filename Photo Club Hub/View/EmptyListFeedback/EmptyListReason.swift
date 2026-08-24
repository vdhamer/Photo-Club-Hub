//
//  EmptyListReason.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 23/08/2026.
//

/// Used for communicating why a screen is showing nothing to the user.
/// Tries to be helpful to user about how to resolve this (displaying an empty list is not very useful).
/// Exactly one case applies, so a screen says one thing instead of stacking hints,
/// and the order in which `resolve` tests them is the priority order.
///
/// Shared by the Clubs, Maps and People tabs, which previously each carried their own copy of this
/// enum and of the chain below — four copies in all, two of them byte-identical (#821).
///
/// The People tab currently doesn't produce `.noCategoriesEnabled`: `photographerPredicate`
/// is hardcoded `TRUEPREDICATE`, so it has no category toggles to switch off.
/// It *can* reach `.categoriesTooStrict`, in the state where
/// photographers are stored but none are usable; its wording table answers that with the same "pull down
/// to load" text as `.databaseEmpty`, which is the correct advice to the user there.
enum EmptyListReason {
    case listHasRows            // no problem, so nothing to explain
    case noCategoriesEnabled    // every relevant category on the Preferences page is switched off
    case buildingDatabase       // startup: data on its way, and the only kind of pass with no spinner of its own
    case refreshing             // pull-to-refresh: its spinner already accounts for the empty screen
    case databaseEmpty          // nothing usable stored, and no load pass is under way
    case searchFilterTooStrict  // rows survive the category filter, but not the Search text
    case categoriesTooStrict    // rows exist, but none in an enabled category

    /// Returns the single reason why a screen is empty,
    /// thereby defining the priority order of warnings across all sccreens.
    ///
    /// The Preferences check comes first deliberately: it reports configuration rather than data, so it
    /// cannot flicker as data comes in, and it names the one action that would help.
    ///
    /// Every case below it can be transient — which is what used to go wrong.
    /// Pull-to-refresh empties the store before reloading it, and the old per-screen chains read that emptiness
    /// as over-filtering, flashing a hint too briefly to read (#821).
    ///
    /// Call this from a caller's `body`: reading the `@Observable` coordinator there is what subscribes
    /// that view to it, so the hint appears and disappears as load passes come and go, with no wiring.
    ///
    /// - Parameters:
    ///   - hasVisibleRows: whether anything survived filtering and is actually on display.
    ///   - allCategoriesOff: the screen's own predicate excludes everything. Always `false` on a screen
    ///     that has no category toggles.
    ///   - storeIsEmpty: an unfiltered probe found no rows of the screen's entity at all.
    ///   - searchIsEmpty: the Search field is blank.
    /// `@MainActor` because it reads `ClubLoadCoordinator.shared`. The four callers are all SwiftUI
    /// views, which are main-actor isolated anyway, so this costs them nothing.
    @MainActor
    static func resolve(hasVisibleRows: Bool,
                        allCategoriesOff: Bool,
                        storeIsEmpty: Bool,
                        searchIsEmpty: Bool) -> EmptyListReason {
        let coordinator = ClubLoadCoordinator.shared

        if hasVisibleRows { return .listHasRows } // no problem
        if allCategoriesOff { return .noCategoriesEnabled } // not transient
        if coordinator.isPerformingStartupLoad { return .buildingDatabase }
        if coordinator.isLoadingOrPending { return .refreshing }
        if storeIsEmpty { return .databaseEmpty }
        return searchIsEmpty ? .categoriesTooStrict : .searchFilterTooStrict
    }
}
