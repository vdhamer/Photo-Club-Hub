//
//  PreludeView2627+Screenshot.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 18/07/2026.
//

import Foundation // for UserDefaults

// Screenshot pipeline only (#776) — no role in normal app use.
// Kept out of PreludeView2627.swift so the mainstream code stays uncluttered.
// See capture-screenshots.sh and ScreenshotReadiness.swift for the pipeline this serves.
//
// Launched with `-initialTab Prelude` (WITHOUT `-skipPrelude YES`) so the splash screen
// is visible. Readiness is signalled once the prelude image asset has loaded.
@available(iOS 26.0, *)
extension PreludeView2627 {

    /// Writes the readiness marker if the app was launched with `-initialTab Prelude` (#776).
    /// Called from PreludeView2627's `.task` after the prelude image has loaded.
    func signalReadyIfInScreenshotMode() {
        ScreenshotReadiness.signalReady(for: "Prelude")
    }

    // -initialTab ⇒ launched by capture-screenshots.sh, which always uses a Debug build.
    // Used by `preludeText` to show the real app name instead of "In debug mode" (#776).
    var isInScreenshotMode: Bool {
        UserDefaults.standard.string(forKey: "initialTab") != nil // launch argument not persisted by UserDefaults
    }

}
