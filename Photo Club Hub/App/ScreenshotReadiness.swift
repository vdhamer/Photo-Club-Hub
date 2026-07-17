//
//  ScreenshotReadiness.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/07/2026.
//

import Foundation // for UserDefaults, FileManager, Data, URL

/// Screenshot pipeline (#776): lets each screen signal "my preset content is now on screen"
/// to `capture-screenshots.sh`. The script polls for a marker file in the app's Documents
/// directory (located via `simctl get_app_container <UDID> <bundle> data`) instead of relying
/// on fixed `sleep`s, and fails the run if the marker doesn't appear within a timeout.
/// Only does anything when the app was launched with `-initialTab` (i.e. in screenshot mode).
enum ScreenshotReadiness {

    /// Deletes a stale marker left behind by a previous launch. Called once at app startup.
    /// The capture script also removes the marker before each launch (belt and braces).
    static func reset() {
        guard UserDefaults.standard.string(forKey: "initialTab") != nil else { return }
        try? FileManager.default.removeItem(at: markerURL)
    }

    /// Writes the marker file, but only if `screen` matches the `-initialTab` launch argument —
    /// so a screen that happens to appear while another screen is being captured cannot
    /// signal readiness on that screen's behalf.
    static func signalReady(for screen: String) {
        guard UserDefaults.standard.string(forKey: "initialTab")?.lowercased()
                == screen.lowercased() else { return }
        try? Data().write(to: markerURL)
    }

    private static var markerURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("screenshot-ready")
    }

}
