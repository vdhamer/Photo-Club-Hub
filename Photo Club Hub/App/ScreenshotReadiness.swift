//
//  ScreenshotReadiness.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/07/2026.
//

import Foundation // for UserDefaults, FileManager, Data, URL
import TipKit     // for Tips.hideAllTipsForTesting

/// Screenshot pipeline (#776): lets each screen signal "my preset content is now on screen"
/// to `capture-screenshots.sh`. The script polls for a marker file in the app's Documents
/// directory (located via `simctl get_app_container <UDID> <bundle> data`) instead of relying
/// on fixed `sleep`s, and fails the run if the marker doesn't appear within a timeout.
/// Only does anything if the app was launched with `-initialTab` (= app is in screenshot mode).
///
/// Declared as a caseless `enum` (rather than a `struct`) to make it uninstantiable by design:
/// the compiler synthesises no `init`, so `ScreenshotReadiness()` is a compile error.
/// A `struct`would need an explicit `@available(*, unavailable)` workaround to achieve the same effect.
enum ScreenshotReadiness {

    // MARK: - initialize without using init()

    // Shared preset for the PortfolioViaClubs and PortfolioViaPeople screens (#777): both
    // routes push the same member's portfolio and jump to the same gallery image, so their
    // captures are near-identical — only the navigation path (Clubs tab vs People tab) differs.
    static let portfolioPresetClubName = "Fotogroep de Gender"
    static let portfolioPresetMemberName = "Francien van Mil"
    static let portfolioPresetImageIndex = 3 // 1-based, i.e. the third gallery image
    private static let readyMarkerFileName = "screenshot-ready"

    /// One-stop startup hook, called once from `PhotoClubHubApp.init` so that file needs a
    /// single screenshot-related line: clears a stale readiness marker (see `reset`) and
    /// honors the `-suppressTips YES` launch argument by hiding all TipKit tips (#776).
    static func configureAtStartup() {
        reset()
        if UserDefaults.standard.bool(forKey: "suppressTips") { // launch arguments -> not persisted by UserDefaults
            Tips.hideAllTipsForTesting()
        }
    }

    /// Deletes a stale marker left behind by a previous launch. Called once at app startup.
    /// The capture script also removes the marker before each launch (belt and braces).
    static func reset() {
        guard UserDefaults.standard.string(forKey: "initialTab") != nil else { return }
        try? FileManager.default.removeItem(at: markerURL)
    }

    // MARK: - signalling when screens are available

    /// SinglePortfolioView's gallery jump serves both Portfolio screen variants; this signals whichever
    /// one is active (each `signalReady(for:)` call is a no-op unless it matches `-initialTab`).
    static func signalReadyForPortfolioPreset() {
        signalReady(for: "PortfolioViaClubs")
        signalReady(for: "PortfolioViaPeople")
    }

    /// Writes the marker file, but only if `screen` matches the `-initialTab` launch argument —
    /// so a screen that happens to appear while another screen is being captured cannot
    /// signal readiness on that screen's behalf.
    static func signalReady(for screen: String) {
        // `initialTab` launch argument not persisted by UserDefaults
        guard UserDefaults.standard.string(forKey: "initialTab")?.lowercased()
                == screen.lowercased() else { return }
        try? Data().write(to: markerURL) // empty file
    }

    private static var markerURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(readyMarkerFileName)
    }

}
