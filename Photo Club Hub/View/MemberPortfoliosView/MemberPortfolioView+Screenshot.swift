//
//  MemberPortfolioView+Screenshot.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/07/2026.
//

import SwiftUI // for Transaction, withTransaction, ScrollViewProxy

// Screenshot pipeline only (#776/#777) — no role in normal app use.
// Kept out of MemberPortfolioView.swift so the mainstream code stays uncluttered. The
// counterpart stored properties (`scrollPresetMembers`, `didApplyPreset`) must remain in
// MemberPortfolioView itself because property wrappers cannot be declared in extensions.
// See capture-screenshots.sh and ScreenshotReadiness.swift for the pipeline this serves.
extension MemberPortfolioView {

    /// The `-initialTab` launch argument (lowercased); drives the screenshot-pipeline presets.
    var initialTabArgument: String? {
        UserDefaults.standard.string(forKey: "initialTab")?.lowercased()
    }

    // -initialTab Clubs ⇒ open scrolled to this section (#776). Nil in normal use.
    var scrollPresetSectionID: String? {
        initialTabArgument == "clubs" ? "Fotogroep de Gender (Eindhoven)" : nil
    }

    // -initialTab PortfolioViaClubs ⇒ push the shared preset member's portfolio and jump its
    // Juicebox-Pro gallery to the preset image (#777). Member, club, and image number live in
    // ScreenshotReadiness, shared with the PortfolioViaPeople twin (PhotographersListView2627).
    var portfolioPresetActive: Bool { initialTabArgument == "portfolioviaclubs" }

    /// Applies the screenshot-pipeline preset (at most one is active per launch, keyed off `-initialTab`):
    /// - `Clubs`: scrolls the `List` to a target `Section` by its `.id()`. A `List` cannot use
    ///   `.scrollPosition(id:)` because that modifier resolves IDs against a `.scrollTargetLayout()`,
    ///   which only applies to a `LazyVStack`/`HStack` inside a `ScrollView` (see MapsView). `List`
    ///   manages its own layout, so we drive it with `ScrollViewReader`'s `scrollTo(_:anchor:)` instead.
    /// - `PortfolioViaClubs`: pushes the preset member's SinglePortfolioView via `selectedPortfolio`,
    ///   latching only once that member's record has been imported (club members arrive progressively).
    func applyScrollPresetIfReady(proxy: ScrollViewProxy) {
        guard didApplyPreset == false, scrollPresetMembers.isEmpty == false else {
            return
        }
        if let target = scrollPresetSectionID {
            didApplyPreset = true
            Task { @MainActor in // wait one runloop tick so the List has laid out the freshly inserted section
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) { proxy.scrollTo(target, anchor: .top) }
                // iOS 26's .sidebarAdaptable tab view plays a sidebar→tab-bar morph on first
                // appearance that can outlast the standard 0.35 s SwiftUI animation budget.
                // onAppear fires while that morph is still running, so signalling immediately
                // would write the marker before the screen is visually settled. A 2 s pause
                // ensures the morph is complete before the capture script sees the marker.
                try? await Task.sleep(for: .seconds(2))
                ScreenshotReadiness.signalReady(for: "Clubs") // #776: tells capture script to stop waiting
            }
        } else if portfolioPresetActive,
                  let member = scrollPresetMembers.first(where: {
                      $0.photographer.fullNameFirstLast == ScreenshotReadiness.portfolioPresetMemberName
                  }) {
            didApplyPreset = true
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { selectedPortfolio = member }
        }
    }

}
