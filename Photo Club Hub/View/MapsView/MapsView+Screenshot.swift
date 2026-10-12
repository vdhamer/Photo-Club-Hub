//
//  MapsView+Screenshot.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/07/2026.
//

import MapKit  // for MKMapSnapshotter, MKMapCamera, MapCamera, CLLocationCoordinate2D
import SwiftUI // for Transaction, withTransaction
import Photo_Club_Hub_Data // for types like Organization

// This extension is for automatic screenshot capture only (#776) — no role in normal app use.
// The properties (`didApplyPreset`, `scrollPositionID`) must remain in MapsView itself because
// property wrappers cannot be declared in extensions.
//
// See capture-screenshots.sh and ScreenshotReadiness.swift for the pipeline this serves.
extension MapsView {

    /// One-shot: retried from `.onAppear` and each `organizations.count` change until the
    /// target organization has been imported, then scrolls to it with animations disabled.
    func applyScrollPresetIfReady() {
        guard didApplyPreset == false,
              let screen = MapsScreenshotPreset.screen,
              let org = organizations.first(where: { MapsScreenshotPreset.isTarget($0) })
            else { return }
        didApplyPreset = true
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            scrollPositionID = org.id
        }
        signalWhenMapTilesReady(for: org, screen: screen) // #776: tells capture script to stop waiting
    }

    // Defers the readiness signal until MapKit tiles for the preset organization's view are loaded.
    // MKMapSnapshotter shares MapKit's internal tile cache with the live Map view, so when
    // the snapshot completes the tiles that the visible map needs are already cached locally.
    // The signal fires whether the snapshot succeeded or failed (network down, timeout, etc.),
    // so the capture script never hangs waiting for a marker that will never appear.
    private func signalWhenMapTilesReady(for org: Organization, screen: String) {
        let options = MKMapSnapshotter.Options()
        if let camera = MapsScreenshotPreset.camera3D(for: org) { // the 3D view's own tiles, not the default view's
            options.camera = MKMapCamera(lookingAtCenter: camera.centerCoordinate,
                                         fromDistance: camera.distance,
                                         pitch: camera.pitch, heading: camera.heading)
        } else {
            options.region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: org.latitude_,
                                               longitude: org.longitude_),
                latitudinalMeters: 10000, longitudinalMeters: 10000
            )
        }
        options.size = CGSize(width: 300, height: 300) // image discarded; only tile cache matters

        let snapshotter = MKMapSnapshotter(options: options)
        Task {
            _ = try? await snapshotter.start() // suppress error; signal readiness either way
            ScreenshotReadiness.signalReady(for: screen)
        }
    }

}

/// The Maps-tab presets of the screenshot pipeline (#776, #880), keyed by the `-initialTab` launch argument.
/// Used by `MapsView` (which card to scroll to), `MapsViewCard` (start unlocked) and `MapsViewMap` (start in 3D).
/// Everything here is nil or false in normal use.
///
/// `MapsMuseum3D` shows two maps in 3D: Fotografiska New York, which it scrolls to, and Fotografiska Berlin, the card
/// above it. New York is near the end of the list, so on an iPad the list can't scroll it to the top and Berlin's
/// card fills the space above it; a flat map there next to a 3D one looked unfinished. On an iPhone, Berlin is off
/// screen, so unlocking it there changes nothing in the capture.
enum MapsScreenshotPreset {

    private typealias Target = ScreenshotReadiness.OrganizationTarget

    private static let fotografiskaNewYork = Target(fullName: "Fotografiska New York", town: "New York City")
    private static let fotografiskaBerlin = Target(fullName: "Fotografiska Berlin", town: "Berlin")

    /// The organization each Maps screen scrolls to. `MapsMuseum3D` also unlocks its map and shows it in 3D.
    private static let targets: [String: Target] = [ // keys are lowercased `-initialTab` values
        "maps": ScreenshotReadiness.targetClub,
        "mapsmuseum": fotografiskaNewYork,
        "mapsmuseum3d": fotografiskaNewYork
    ]

    /// The 3D views of `MapsMuseum3D`, tilted and north up: New York zoomed in on Fotografiska with Madison Square
    /// Park in view, Berlin centered on the museum. Computed rather than stored: `MapCamera` isn't `Sendable`, so it
    /// can't be a `static let`.
    private static func camera3D(for target: Target) -> MapCamera? {
        switch target {
        case fotografiskaNewYork:
            MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 40.7408, longitude: -73.9872),
                      distance: 1000, heading: 0, pitch: 55)
        case fotografiskaBerlin:
            MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: 52.52728, longitude: 13.38638),
                      distance: 1000, heading: 0, pitch: 55)
        default:
            nil
        }
    }

    /// The organizations whose maps `MapsMuseum3D` shows unlocked and in 3D.
    private static let targets3D = [fotografiskaNewYork, fotografiskaBerlin]

    private static var initialTab: String? {
        UserDefaults.standard.string(forKey: "initialTab")?.lowercased() // launch argument, not persisted
    }

    /// The `-initialTab` value if it names a Maps screen, used to signal readiness for that screen. Nil otherwise.
    static var screen: String? {
        guard let initialTab, targets[initialTab] != nil else { return nil }
        return initialTab
    }

    /// Whether `organization` is the one the current Maps screen scrolls to.
    static func isTarget(_ organization: Organization) -> Bool {
        guard let initialTab, let target = targets[initialTab] else { return false }
        return Target(organization) == target
    }

    /// Whether this organization's card starts with its map unlocked (`MapsMuseum3D` only).
    static func startsUnlocked(_ organization: Organization) -> Bool {
        target3D(of: organization) != nil
    }

    /// The camera this organization's map starts with instead of its default view (`MapsMuseum3D` only).
    static func camera3D(for organization: Organization) -> MapCamera? {
        target3D(of: organization).flatMap { camera3D(for: $0) }
    }

    private static func target3D(of organization: Organization) -> Target? {
        guard initialTab == "mapsmuseum3d" else { return nil }
        let target = Target(organization)
        return targets3D.contains(target) ? target : nil
    }

}
