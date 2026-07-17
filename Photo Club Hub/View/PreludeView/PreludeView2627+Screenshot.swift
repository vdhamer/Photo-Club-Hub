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

}
