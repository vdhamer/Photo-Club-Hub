//
//  ScreenshotReadinessTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 17/07/2026.
//

import Testing
import Foundation
@testable import Photo_Club_Hub

// UserDefaults.standard["initialTab"] and the Documents/screenshot-ready marker file are global singletons,
// so tests that touch them must run serially to avoid inter-test interference.
// (The test plan runs suites in parallel, but `.serialized` only affects within-suite ordering.)

// Higher level tests can be found in verify-screenshots.sh,
// but that needs to be run outside the test plan because it is a script.
@Suite("Tests the ScreenshotReadiness marker-file and launch-arg logic", .serialized)
struct ScreenshotReadinessTests {

    // Mirrors the private ScreenshotReadiness.markerURL.
    private let markerURL: URL = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("screenshot-ready")

    // Resets shared state before and after each test (belt and suspenders).
    private func cleanup() {
        UserDefaults.standard.removeObject(forKey: "initialTab")
        try? FileManager.default.removeItem(at: markerURL)
    }

    // MARK: - signalReady(for:)

    @Test("signalReady writes the marker when initialTab matches")
    func signalReadyWritesMarkerOnMatch() {
        cleanup(); defer { cleanup() }
        UserDefaults.standard.set("clubs", forKey: "initialTab")
        ScreenshotReadiness.signalReady(for: "Clubs")
        #expect(FileManager.default.fileExists(atPath: markerURL.path))
    }

    @Test("signalReady skips the marker when initialTab does not match")
    func signalReadySkipsMarkerOnMismatch() {
        cleanup(); defer { cleanup() }
        UserDefaults.standard.set("maps", forKey: "initialTab")
        ScreenshotReadiness.signalReady(for: "Clubs")
        #expect(!FileManager.default.fileExists(atPath: markerURL.path))
    }

    @Test("signalReady matching is case-insensitive")
    func signalReadyCaseInsensitive() {
        cleanup(); defer { cleanup() }
        UserDefaults.standard.set("CLUBS", forKey: "initialTab")
        ScreenshotReadiness.signalReady(for: "clubs")
        #expect(FileManager.default.fileExists(atPath: markerURL.path))
    }

    @Test("signalReady is a no-op when initialTab is absent")
    func signalReadyNoopsWithoutInitialTab() {
        cleanup(); defer { cleanup() }
        ScreenshotReadiness.signalReady(for: "Clubs")
        #expect(FileManager.default.fileExists(atPath: markerURL.path) == false)
    }

    // MARK: - reset()

    @Test("reset removes an existing marker when initialTab is set")
    func resetDeletesMarker() throws {
        cleanup(); defer { cleanup() }
        try Data().write(to: markerURL)
        UserDefaults.standard.set("clubs", forKey: "initialTab")
        ScreenshotReadiness.reset()
        #expect(FileManager.default.fileExists(atPath: markerURL.path) == false)
    }

    @Test("reset is a no-op when initialTab is absent")
    func resetNoopsWithoutInitialTab() throws {
        cleanup(); defer { cleanup() }
        try Data().write(to: markerURL)
        // initialTab not set — reset() should leave the marker untouched
        ScreenshotReadiness.reset()
        #expect(FileManager.default.fileExists(atPath: markerURL.path))
    }

    // MARK: - signalReadyForPortfolioPreset()

    @Test("signalReadyForPortfolioPreset writes the marker for PortfolioViaClubs")
    func portfolioPresetSignalsViaClubs() {
        cleanup(); defer { cleanup() }
        UserDefaults.standard.set("portfolioviaclubs", forKey: "initialTab")
        ScreenshotReadiness.signalReadyForPortfolioPreset()
        #expect(FileManager.default.fileExists(atPath: markerURL.path))
    }

    @Test("signalReadyForPortfolioPreset writes the marker for PortfolioViaPeople")
    func portfolioPresetSignalsViaPeople() {
        cleanup(); defer { cleanup() }
        UserDefaults.standard.set("portfolioviapeople", forKey: "initialTab")
        ScreenshotReadiness.signalReadyForPortfolioPreset()
        #expect(FileManager.default.fileExists(atPath: markerURL.path))
    }

}
