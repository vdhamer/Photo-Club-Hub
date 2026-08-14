//
//  Bundle+VersionBuild.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/05/2022.
//

import Foundation

extension Bundle {

    var shortVersion: String {
        if let result = infoDictionary?["CFBundleShortVersionString"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }

    var buildVersion: String {
        if let result = infoDictionary?["CFBundleVersion"] as? String {
            return result
        } else {
            assert(false)
            return ""
        }
    }

    var fullVersion: String {
        return "\(shortVersion) (\(buildVersion))"
    }

    /// When this binary was built, e.g. `9 aug 2026, 22:40`, in the user's own locale.
    ///
    /// Reads the `BuildDate` key that the *Run GateAndStamp script* build phase writes into the built
    /// `Info.plist` (see #808), and returns `nil` for a binary built without that phase so callers can
    /// show a placeholder rather than something misleading.
    ///
    /// The version and build number are frozen for a whole release cycle, so this is what orders the
    /// Debug installs sitting on test devices; `gitCommit` is what pins each one to a commit.
    var buildDate: String? {
        guard let stored = infoDictionary?["BuildDate"] as? String else { return nil }

        // The stamp is local time without an offset — deliberately not ISO 8601, so parse it with a
        // fixed format and a POSIX locale, then display it in the user's own locale.
        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.dateFormat = "yyyy-MM-dd'T'HH:mm"
        guard let date = parser.date(from: stored) else { return stored } // show it raw rather than lie
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    /// The commit this binary was built from, shortened to 7 characters, e.g. `d164ab6`.
    ///
    /// Seven characters because that is what GitHub shows, so the value can be compared by eye with a
    /// commit listing, and `git show d164ab6` resolves it. A `-dirty` suffix means the build contained
    /// uncommitted changes and is deliberately kept: on a test device that is information, not an
    /// error. An archived build can never show it, because the build phase refuses to archive a dirty
    /// tree. Returns `nil` for a binary built without that phase.
    var gitCommit: String? {
        guard let hash = infoDictionary?["GitCommitHash"] as? String else { return nil }
        return hash.hasSuffix("-dirty") ? "\(hash.prefix(7))-dirty" : String(hash.prefix(7))
    }
}
