//
//  SettingsBundleKeysTest.swift
//  Photo Club HubTests
//
//  Created by Claude Code under guidance of Peter van den Hamer on 20/08/2026.
//

import Testing
import Foundation
@testable import Photo_Club_Hub

// Each BuildStampKey is a string literal that also appears, by hand, as a `Key` in
// Settings.bundle/Root.plist. Nothing in the compiler ties the two together: rename one side only and
// the app keeps building, while the Settings pane silently shows that row's DefaultValue placeholder
// forever. These tests are that missing link (#820).
@Suite("Checks that BuildStampKey and Settings.bundle/Root.plist agree")
struct SettingsBundleKeysTests {

    /// The `Key`/`Type` pairs of every row in Root.plist, read from the built app bundle.
    ///
    /// Addressed via `bundleURL` rather than `url(forResource:subdirectory:)` because Settings.bundle
    /// is a nested bundle wrapper copied to the app bundle root, not a flattened resource.
    private static func rootPlistSpecifiers() throws -> [(key: String, type: String)] {
        let url = Bundle.main.bundleURL
            .appendingPathComponent("Settings.bundle")
            .appendingPathComponent("Root.plist")
        try #require(FileManager.default.fileExists(atPath: url.path),
                     "No Root.plist at \(url.path) — is Settings.bundle still in Copy Bundle Resources?")
        let plist = try PropertyListSerialization.propertyList(from: Data(contentsOf: url),
                                                              options: [],
                                                              format: nil) as? [String: Any]
        let specifiers = try #require(plist?["PreferenceSpecifiers"] as? [[String: Any]],
                                      "Root.plist has no PreferenceSpecifiers array")
        return specifiers.compactMap { specifier in
            guard let key = specifier["Key"] as? String else { return nil } // group headers have no Key
            return (key, specifier["Type"] as? String ?? "")
        }
    }

    @Test("Root.plist has a row for every build stamp the app writes")
    func rootPlistExposesEveryBuildStampKey() throws {
        let plistKeys: Set<String> = Set(try Self.rootPlistSpecifiers().map(\.key))
        for key in BuildStampKey.allCases {
            #expect(plistKeys.contains(key.rawValue),
                    """
                    Root.plist has no row with Key '\(key.rawValue)', so the Settings app will keep \
                    showing that row's DefaultValue instead of the value the app writes
                    """)
        }
    }

    @Test("The build-stamp rows stay read-only labels, not editable controls")
    func buildStampRowsAreTitleValueSpecifiers() throws {
        let typesByKey: [String: String]  = Dictionary(uniqueKeysWithValues: try Self.rootPlistSpecifiers())
        for key in BuildStampKey.allCases {
            #expect(typesByKey[key.rawValue] == "PSTitleValueSpecifier",
                    """
                    '\(key.rawValue)' should be a read-only PSTitleValueSpecifier: these stamps are \
                    outputs written by the app, not settings the user can change
                    """)
        }
    }

    @Test("The obsolete _preference keys are gone from Root.plist")
    func rootPlistNoLongerUsesPreferenceSuffix() throws {
        let plistKeys = Set(try Self.rootPlistSpecifiers().map(\.key))
        for staleKey in BuildStampKey.deprecatedKeys {
            #expect(plistKeys.contains(staleKey) == false,
                    "Root.plist still refers to the pre-#820 key '\(staleKey)'")
        }
    }

    @Test("No build stamp is listed as both current and obsolete")
    func currentAndDeprecatedKeysDoNotOverlap() {
        let current = Set(BuildStampKey.allCases.map(\.rawValue))
        let deprecated = Set(BuildStampKey.deprecatedKeys)
        #expect(current.isDisjoint(with: deprecated),
                """
                removeDeprecatedKeys() would delete a key the app still writes: \
                \(current.intersection(deprecated).sorted())
                """)
    }
}

// Mutates UserDefaults.standard, a process-wide singleton, so these run serially and clean up after
// themselves. Only the obsolete keys are touched — nothing reads those any more.
@Suite("Checks the one-time cleanup of the obsolete _preference keys", .serialized)
struct BuildStampKeyCleanupTests {

    private func removeAllDeprecateds() {
        for key in BuildStampKey.deprecatedKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    @Test("removeDeprecatedKeys() clears every obsolete key")
    func removeDeprecatedKeysClearsThemAll() {
        removeAllDeprecateds()
        defer { removeAllDeprecateds() }

        for key in BuildStampKey.deprecatedKeys {
            UserDefaults.standard.set("stale value", forKey: key)
        }

        BuildStampKey.removeDeprecatedKeys()

        for key in BuildStampKey.deprecatedKeys {
            #expect(UserDefaults.standard.object(forKey: key) == nil,
                    "'\(key)' survived removeDeprecatedKeys()")
        }
    }

    @Test("removeDeprecatedKeys() is harmless when the keys are already absent")
    func removeDeprecatedKeysIsIdempotent() {
        removeAllDeprecateds()
        defer { removeAllDeprecateds() }

        BuildStampKey.removeDeprecatedKeys() // must not trap on missing keys
        BuildStampKey.removeDeprecatedKeys()

        for key in BuildStampKey.deprecatedKeys {
            #expect(UserDefaults.standard.object(forKey: key) == nil)
        }
    }
}
