//
//  BuildStampKey.swift
//  Photo Club Hub
//
//  Created by Claude Code under guidance by Peter van den Hamer on 20/08/2026.
//

import Foundation // for UserDefaults

/// Keys under which the app publishes read-only build "stamps" for the iOS Settings app to display.
///
/// These are outputs, not settings: the matching rows in `Settings.bundle/Root.plist` are
/// `PSTitleValueSpecifier`s, so the user cannot change them. That is why they use the same plain
/// lowerCamelCase as every other key in the app rather than the old `_preference` suffix, which came
/// from Apple's Settings Application Schema sample code and described user-settable preferences (#820).
///
/// Each case's `rawValue` must match a `Key` in `Root.plist`, otherwise the Settings pane silently
/// keeps showing that row's `DefaultValue` placeholder. Nothing in the compiler enforces that, so
/// `SettingsBundleKeysTests` asserts it instead.
enum BuildStampKey: String, CaseIterable {
    case appVersion
    case appBuildDate
    case appGitCommit
    case libraryVersion
    case libraryCommit
    case libraryCommitDate

    /// The `_preference`-suffixed names used up to and including release 3.0.x.
    ///
    /// Nothing reads these any more. They are swept once on launch purely so that `defaults read`
    /// and the Settings pane do not keep reporting values from a build that is long gone. Mirrors the
    /// `prevUserDefaultsKeys` approach in the Data package's `Settings.swift`.
    static let deprecatedKeys: [String] = ["version_preference",
                                           "buildDate_preference",
                                           "gitCommit_preference",
                                           "libraryVersion_preference",
                                           "libraryCommit_preference",
                                           "libraryCommitDate_preference"]

    /// Stores `value` so that the corresponding row in the iOS Settings app can display it.
    func set(_ value: String) {
        UserDefaults.standard.set(value, forKey: rawValue)
    }

    /// Removes the obsolete `_preference` keys. Safe to call on every launch: `removeObject` on an
    /// absent key does nothing.
    static func removeDeprecatedKeys() {
        for deprecatedKey in deprecatedKeys {
            UserDefaults.standard.removeObject(forKey: deprecatedKey)
        }
    }
}
