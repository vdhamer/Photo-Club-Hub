//
//  MapsView+Screenshot.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/07/2026.
//

import SwiftUI // for Transaction, withTransaction

// This extension is for automatic screenshot capture only (#776) — no role in normal app use.
// The properties (`didApplyPreset`, `scrollPositionID`) must remain in MapsView itself because
// property wrappers cannot be declared in extensions.
//
// See capture-screenshots.sh and creenshotReadiness.swift for the pipeline this serves.
extension MapsView {

    private static let clubNameForScreenshot = "Fotogroep de Gender"

    // -initialTab Maps ⇒ open scrolled to this club. Nil in normal use.
    var scrollPresetFullName: String? {
        UserDefaults.standard.string(forKey: "initialTab")?.lowercased() == "maps"
            ? Self.clubNameForScreenshot : nil
    }

    /// One-shot: retried from `.onAppear` and each `organizations.count` change until the
    /// target club has been imported, then scrolls to it with animations disabled.
    func applyScrollPresetIfReady() {
        guard didApplyPreset==false, let target = scrollPresetFullName,
              let org = organizations.first(where: { $0.fullName == target }) else { return }
        didApplyPreset = true
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            scrollPositionID = org.id
        }
        ScreenshotReadiness.signalReady(for: "Maps") // #776: tells capture script to stop waiting
    }

}
