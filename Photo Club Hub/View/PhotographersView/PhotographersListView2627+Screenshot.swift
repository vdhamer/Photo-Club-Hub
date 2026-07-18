//
//  PhotographersListView2627+Screenshot.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/07/2026.
//

import SwiftUI // for Transaction, withTransaction

// Screenshot pipeline only (#776/#777) — no role in normal app use.
// Kept out of PhotographersListView2627.swift so the mainstream code stays uncluttered. The
// counterpart stored properties (`photographers`, `didApplyPreset`, `scrollPositionID`) must
// remain in PhotographersListView2627 itself because property wrappers cannot be declared in
// extensions. The pre-iOS-26 sibling (PhotographersListView1718) deliberately has no
// equivalent: capture-screenshots.sh does not support iOS 17/18 simulators.
@available(iOS 26.0, *)
extension PhotographersListView2627 {

    // -initialTab People ⇒ open scrolled to this photographer's card ("Osinski, Edjoe") anchored
    // at the top, so the next card ("Otter, Rien den") peeks in below it (#776). Nil in normal use.
    var scrollPresetPhotographerName: String? {
        UserDefaults.standard.string(forKey: "initialTab")?.lowercased() == "people"
            ? "Edjoe Osinski" : nil
    }

    // -initialTab PortfolioViaPeople ⇒ push the shared preset member's portfolio (#777); the
    // People-tab twin of MemberPortfolioView's PortfolioViaClubs, producing a near-identical capture.
    var portfolioPresetActive: Bool {
        UserDefaults.standard.string(forKey: "initialTab")?.lowercased() == "portfolioviapeople"
    }

    /// Applies the screenshot-pipeline preset (at most one is active per launch, keyed off `-initialTab`):
    /// - `People`: one-shot scroll, retried from `.onAppear` and each `photographers.count` change
    ///   until the target photographer has been imported.
    /// - `PortfolioViaPeople`: pushes the preset member's SinglePortfolioView via `selectedPortfolio`,
    ///   latching only once her de Gender membership record has been imported.
    func applyScrollPresetIfReady() {
        guard !didApplyPreset else { return }
        if let target = scrollPresetPhotographerName,
           let photographer = photographers.first(where: { $0.fullNameFirstLast == target }) {
            didApplyPreset = true
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { scrollPositionID = photographer.id }
            ScreenshotReadiness.signalReady(for: "People") // #776: tells capture script to stop waiting
        } else if portfolioPresetActive,
                  let member = photographers
                      .first(where: { $0.fullNameFirstLast == ScreenshotReadiness.portfolioPresetMemberName })?
                      .memberships
                      .first(where: { $0.organization.fullName == ScreenshotReadiness.portfolioPresetClubName }) {
            didApplyPreset = true
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) { selectedPortfolio = member }
        }
    }

}
