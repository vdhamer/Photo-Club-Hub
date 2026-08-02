//
//  ReleaseTrainTest.swift
//  Photo Club HubTests
//
//  Created by Claude Code (guided by Peter van den Hamer) on 02/08/2026.
//

import Testing
import Foundation
import Photo_Club_Hub_Data // for PhotoClubHubDataVersion
@testable import Photo_Club_Hub // for AppVersion and Bundle.shortVersion

// The three repositories (Photo-Club-Hub, Photo-Club-Hub-HTML, Photo-Club-Hub-Data) share a
// synchronized major.minor release train, while patch floats independently per repo. See #769 step 8(0).
//
// Deliberately compares major.minor only: comparing full versions would fail on the floating patch,
// e.g. app 2.11.0 against package 2.11.1 is the expected state, not a mismatch.
@Suite("Tests that app and package are on the same release train")
struct ReleaseTrainTests {

    @Test("App and package share the same major.minor")
    func appAndPackageShareMajorMinor() {
        let app = AppVersion()                                   // reads Bundle.main.shortVersion
        let package = AppVersion(PhotoClubHubDataVersion.semver)  // e.g. "2.11.1"

        // AppVersion returns (0,0,0) when a version string fails to parse. Without this guard, two
        // unparseable strings would compare equal and the test would pass while proving nothing.
        #expect(!(package.major == 0 && package.minor == 0 && package.patch == 0),
                "Could not parse PhotoClubHubDataVersion.semver: \(PhotoClubHubDataVersion.semver)")
        #expect(!(app.major == 0 && app.minor == 0 && app.patch == 0),
                "Could not parse the app's MARKETING_VERSION: \(Bundle.main.shortVersion)")

        #expect(app.major == package.major,
                """
                App major (\(app.major)) differs from package major (\(package.major)). \
                Bump MARKETING_VERSION, or the package, so both are on one train.
                """)
        #expect(app.minor == package.minor,
                """
                App minor (\(app.minor)) differs from package minor (\(package.minor)). \
                Bump MARKETING_VERSION, or the package, so both are on one train.
                """)
    }
}
