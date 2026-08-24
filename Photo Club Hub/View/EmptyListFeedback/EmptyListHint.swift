//
//  EmptyListHint.swift
//  Photo Club Hub
//
//  Created by Claude Code guided by Peter van den Hamer on 23/08/2026.
//
//  Two types live here because they are two layers of one thing: the box, and the decision to show it.
//
//  * `EmptyListHint` is what a list screen instantiates. Hand it a reason, a tint and the screen's own
//    wording, and it picks between a box, a spinner, and showing nothing. Start here.
//  * `CalloutBox` is the box itself: a `Text` in a rounded, tinted frame, with no opinion about when it
//    belongs on screen. Instantiate it directly only for a remark that is not about an empty list;
//    `MemberPortfolioView` also borrows its three styling constants for the TipKit tips above it.
//
//  The current callers are the four "Filtered…" views of the Clubs, Maps and People tabs
//  (People has one view per iOS version), all of which use `EmptyListHint`.
//

import SwiftUI // for View

/// Renders the hint chosen by `EmptyListReason.resolve`, or nothing when the screen speaks for itself.
///
/// A screen adds this as the last element of its `List` content, after the `ForEach` over its rows, and
/// supplies two private helpers of its own — one wrapping `resolve`, one holding the wording:
/// ```swift
/// EmptyListHint(reason: emptyListReason(), // private func: the screen's inputs → EmptyListReason
///               tint: .mapsColor,          // the color of the tab showing the hint
///               wording: hintText)         // private func (EmptyListReason) -> Text?
///     .padding(.horizontal) // only where the surrounding rows bring their own padding
/// ```
/// Both helpers are called from `body`, which matters: `resolve` reads the `@Observable`
/// `ClubLoadCoordinator`, and reading it there is what subscribes the screen to load-state changes, so the
/// hint comes and goes with the load passes. See `FilteredMapsView` for a worked example.
///
/// Because a non-empty list is one of the reasons, the hint is added unconditionally: there is no `if` at
/// the call site, and no separate "empty state" branch in the screen. `body` returns nothing at all for
/// the silent reasons.
///
/// `wording` deliberately stays with the screen that uses it: only that screen knows what to call its own
/// rows ("names", "clubs and museums", "photographers"), and keeping the strings next to the view makes
/// them findable when the wording is reviewed. Everything else — which reasons stay silent, and the one
/// reason that gets a spinner instead of a box — is the same on all three tabs and lives here.
struct EmptyListHint: View { // wraps CalloutBox, which can also be instantiated directly

    /// Why the list is empty, and thus which hint to show. Normally comes straight from
    /// `EmptyListReason.resolve`, called from the caller's `body`. `.listHasRows` is a legitimate value:
    /// it renders nothing, which is what lets the call site skip an `if`.
    let reason: EmptyListReason
    /// The color of the tab showing the hint, passed on to `CalloutBox.tint`. Ignored by the spinner branch.
    let tint: Color
    /// The screen's own wording table, normally a `switch` over every case of `EmptyListReason`.
    /// Returns `nil` for the reasons that should show nothing at all: `.listHasRows` and `.refreshing` on
    /// every screen, plus whatever else a given screen has no useful advice for. Returning `nil` for
    /// `.buildingDatabase` is the convention, as this view answers that case with a spinner regardless.
    let wording: (EmptyListReason) -> Text?

    /// Nothing here stops the spinner: this view holds no state, so the `ProgressView` is simply absent
    /// the next time `body` runs with a different `reason`. In practice it goes when the first rows arrive
    /// — `resolve` then answers `.listHasRows` and this whole view renders nothing — or, on an empty
    /// startup load, when `isPerformingStartupLoad` goes false and the `.databaseEmpty` box takes over.
    /// Reading the `@Observable` coordinator from the caller's `body` is what triggers that re-evaluation.
    ///
    /// It therefore spins forever in a state where the startup pass is never requested *and* is not
    /// expected to be: `RootView` skips `loadIfIdle()` in tests and Xcode previews, leaving
    /// `isPerformingStartupLoad` true for the whole run. Manual-loading mode is exempt by design — see
    /// `ClubLoadCoordinator.isPerformingStartupLoad`.
    var body: some View {
        if reason == .buildingDatabase { // the one pass with no spinner of its own, so supply one
            ProgressView()
                .frame(maxWidth: .infinity)
        } else if let text = wording(reason) {
            CalloutBox(text: text, tint: tint)
        }
    }

}

// MARK: - CalloutBox

/// A boxed remark styled just like the TipKit tips at the top of the various list screens:
/// same corner radius, screen color border and wash — but without TipKit's control logic.
///
/// TipKit was considered as a candidate for these messages but is not appropriate here: a `Tip` is a one-time
/// discovery aid backed by a datastore, with a one-way `invalidate` and no per-tip way back. The callout
/// messages report the current state, so they should return whenever the same state occurs again. (#821).
///
/// The styling is duplicated by `MemberPortfolioView.calloutTipStyle()` rather than shared, because
/// `.tipCornerRadius` and `.tipBackground` only exist on `TipView`; that extension reads these same
/// constants so the Tips and the Callouts below them stay one look.
///
/// ```swift
/// CalloutBox(text: Text("The map is locked.", tableName: "PhotoClubHub.SwiftUI", comment: "…"),
///            tint: .mapsColor)
/// ```
/// The box hides its own list row separator, so it needs no `.listRowSeparator(.hidden)` from the caller,
/// but it brings no outer padding: inside a `List` that is already inset it needs none, and elsewhere the
/// caller adds what its layout calls for.
struct CalloutBox: View {

    /// The remark to box. A `Text` rather than a `String`, so the caller keeps control of localization and
    /// of any inline markup or links; the box only supplies the frame.
    let text: Text
    /// The color of the screen showing the box — `.clubsColor`, `.mapsColor` or `.peopleColor` — which is
    /// what lets one box explain an empty list on all three tabs. Used for both the border and the wash.
    let tint: Color

    // Read by `MemberPortfolioView.calloutTipStyle()` as well, which is why these are not private.
    static let cornerRadius: CGFloat = 12
    static let borderWidth: CGFloat = 1.5
    static let backgroundOpacity: CGFloat = 0.15

    var body: some View {
        text
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tint.opacity(Self.backgroundOpacity),
                        in: RoundedRectangle(cornerRadius: Self.cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: Self.cornerRadius)
                    .strokeBorder(tint, lineWidth: Self.borderWidth)
            }
            .tint(.primary)
            .listRowSeparator(.hidden)
    }

}

// MARK: - Previews

// Believe it or not, this preview actually works
// It displays the various callouts in appropriate colors.

#Preview {
    VStack(spacing: 12) {
        CalloutBox(text: Text(verbatim: "A callout in the Maps color."), tint: .mapsColor)
        CalloutBox(text: Text(verbatim: "A callout in the Clubs color."), tint: .clubsColor)
        CalloutBox(text: Text(verbatim: "A callout in the People color."), tint: .peopleColor)

        // .buildingDatabase is the one reason that renders a spinner rather than a box.
        HStack {
            Text(verbatim: "BuildingDatabase:")
            Spacer()
        }
        EmptyListHint(reason: .buildingDatabase, tint: .clubsColor) { _ in nil }

        // A screen's own wording returns nil for the silent reasons, so this renders nothing at all.
        HStack {
            Text(verbatim: "ListHasRows:")
            Spacer()
        }
        EmptyListHint(reason: .listHasRows, tint: .clubsColor) { reason in
            reason == .listHasRows ? nil : Text(verbatim: "unused in this preview")
        }
    }
    .padding()
}
