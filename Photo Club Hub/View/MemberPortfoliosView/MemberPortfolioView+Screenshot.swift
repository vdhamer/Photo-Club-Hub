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

    // -initialTab PortfolioViaClubs ⇒ push this member's portfolio (member of the club fetched
    // by `scrollPresetMembers`) and jump its Juicebox-Pro gallery to this image (#777).
    var portfolioPresetActive: Bool { initialTabArgument == "portfolioviaclubs" }
    static let portfolioPresetMemberName = "Francien van Mil"
    static let portfolioPresetImageIndex = 3 // 1-based, i.e. the third gallery image

    /// Applies the screenshot-pipeline preset (at most one is active per launch, keyed off `-initialTab`):
    /// - `Clubs`: scrolls the `List` to a target `Section` by its `.id()`. A `List` cannot use
    ///   `.scrollPosition(id:)` because that modifier resolves IDs against a `.scrollTargetLayout()`,
    ///   which only applies to a `LazyVStack`/`HStack` inside a `ScrollView` (see MapsView). `List`
    ///   manages its own layout, so we drive it with `ScrollViewReader`'s `scrollTo(_:anchor:)` instead.
    /// - `PortfolioViaClubs`: pushes the preset member's SinglePortfolioView via `selectedPortfolio`,
    ///   latching only once that member's record has been imported (club members arrive progressively).
    func applyScrollPresetIfReady(proxy: ScrollViewProxy) {
        guard !didApplyPreset, !scrollPresetMembers.isEmpty else { return }
        if let target = scrollPresetSectionID {
            didApplyPreset = true
            Task { @MainActor in // wait one runloop tick so the List has laid out the freshly inserted section
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) { proxy.scrollTo(target, anchor: .top) }
                ScreenshotReadiness.signalReady(for: "Clubs") // #776: tells capture script to stop waiting
            }
        } else if portfolioPresetActive,
                  let member = scrollPresetMembers.first(where: {
                      $0.photographer.fullNameFirstLast == Self.portfolioPresetMemberName
                  }) {
            didApplyPreset = true
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { selectedPortfolio = member }
        }
    }

}
