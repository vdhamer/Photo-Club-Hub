//
//  RocketSimBug1085Test.swift
//  Photo Club HubTests
//
//  Created by Claude Code (guided by Peter van den Hamer) on 22/07/2026.
//

import Testing
import Foundation

// Canary for AvdLee/RocketSimApp#1085: RocketSim 16.3/16.4 crashes with a SIGTRAP in
// FBSimulatorControl.inferSimulatorConfiguration on every CLI screenshot request.
// capture-screenshots.sh and verify-screenshots.sh work around it by falling back to
// unframed `xcrun simctl io screenshot` whenever the framed rocketsim call fails.
//
// This test
//  - PASSES while the installed RocketSim is a confirmed-broken version (meaning the workaround is still needed).
//  - FAILS when a new RocketSim ships whose version is not yet in confirmedBroken
// Failure is signal to run scripts/check-rocketsim-bug-1085.sh to determine whether the crash is fixed.
@Suite("RocketSim upstream bug canaries")
struct RocketSimBug1085Tests {

    let confirmedBroken: Set<String> = ["16.3", "16.4"]

    @Test("Installed RocketSim is a known-broken version for screenshot crash #1085")
    func installedRocketSimVersionIsKnownBroken() {
        guard let version = installedRocketSimVersion() else { return } // not installed → skip

        // Versions confirmed to reproduce the #1085 screenshot crash.
        //
        // When a new RocketSim ships and this test fails, run:
        //   scripts/check-rocketsim-bug-1085.sh
        //
        // Based on the result:
        //   • Crash still reproduces → add the new version here and re-run tests
        //   • Crash is gone         → remove the RS_BROKEN fallback paths from
        //                             capture-screenshots.sh and verify-screenshots.sh,
        //                             then delete this test and the canary script
        let majorMinor = version.split(separator: ".").prefix(2).joined(separator: ".")

        let msg = "RocketSim \(version) is outside the known-broken set \(confirmedBroken). "
            + "Run scripts/check-rocketsim-bug-1085.sh to probe whether #1085 still reproduces. "
            + "Still broken: add \"\(majorMinor)\" to confirmedBroken in this test. "
            + "Fixed: remove the RS_BROKEN workarounds from capture-screenshots.sh "
            + "and verify-screenshots.sh, then delete this test and check-rocketsim-bug-1085.sh."
        #expect(confirmedBroken.contains(majorMinor), Comment(rawValue: msg))
    }

    // Reads the version of the latest RocketSim.app from its bundle Info.plist.
    // Checks /Applications first, then ~/Applications.
    // Returns nil when RocketSim.app is absent from both locations.
    // Does NOT check "RocketSim 16.2.app" — that is the pre-bug workaround and
    // is irrelevant to whether the current version has the #1085 crash.
    private func installedRocketSimVersion() -> String? {
        let appName = "RocketSim.app"
        let plistSubpath = "Contents/Info.plist"
        let searchRoots = ["/Applications", "\(NSHomeDirectory())/Applications"]
        for root in searchRoots {
            let path = "\(root)/\(appName)/\(plistSubpath)"
            guard FileManager.default.fileExists(atPath: path),
                  let plist = NSDictionary(contentsOfFile: path),
                  let version = plist["CFBundleShortVersionString"] as? String
            else { continue }
            return version
        }
        return nil
    }
}
