//
//  MapsView+Screenshot.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/07/2026.
//

import MapKit  // for MKMapSnapshotter, MKCoordinateRegion, CLLocationCoordinate2D
import SwiftUI // for Transaction, withTransaction

// This extension is for automatic screenshot capture only (#776) — no role in normal app use.
// The properties (`didApplyPreset`, `scrollPositionID`) must remain in MapsView itself because
// property wrappers cannot be declared in extensions.
//
// See capture-screenshots.sh and ScreenshotReadiness.swift for the pipeline this serves.
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
        guard didApplyPreset == false, let target = scrollPresetFullName,
              let org = organizations.first(where: { $0.fullName == target }) else { return }
        didApplyPreset = true
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            scrollPositionID = org.id
        }
        signalWhenMapTilesReady(for: org) // #776: tells capture script to stop waiting
    }

    // Defers the readiness signal until MapKit tiles for the preset club's region are loaded.
    // MKMapSnapshotter shares MapKit's internal tile cache with the live Map view, so when
    // the snapshot completes the tiles the visible map needs are already cached locally.
    // The signal fires whether the snapshot succeeded or failed (network down, timeout, etc.),
    // so the capture script never hangs waiting for a marker that will never appear.
    private func signalWhenMapTilesReady(for org: Organization) {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: org.latitude_,
                                           longitude: org.longitude_),
            latitudinalMeters: 10000, longitudinalMeters: 10000
        )
        options.size = CGSize(width: 300, height: 300) // image discarded; only tile cache matters

        let snapshotter = MKMapSnapshotter(options: options)
        Task {
            _ = try? await snapshotter.start() // suppress error; signal readiness either way
            ScreenshotReadiness.signalReady(for: "Maps")
        }
    }

}
