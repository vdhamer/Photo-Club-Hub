//
//  Bundle+VersionBuild.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/05/2022.
//

import Foundation

extension Bundle {

    var shortVersion: String { // e.g. "2.12.3"
        if let result = infoDictionary?["CFBundleShortVersionString"] as? String {
            return result
        } else {
            assert(false)
            return "No version#"
        }
    }

    var buildVersion: String { // e.g. "1234"
        if let result = infoDictionary?["CFBundleVersion"] as? String {
            return result
        } else {
            assert(false)
            return "No build#"
        }
    }

    var fullVersion: String { // e.g. "2.12.3 (1234)"
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

    /// The Photo Club Hub Data version this binary was built against, e.g. `3.0.0`.
    ///
    /// Reads the `LibraryVersion` and `LibraryRevision` keys that the *Run GateAndStamp script* build
    /// phase copies from the `Package.resolved` that Xcode actually resolved (see
    /// vdhamer/Photo-Club-Hub#814). This replaces a hand-maintained constant in the package, which
    /// could not tell two binaries apart when they were built against different package commits
    /// carrying the same version number.
    ///
    /// Where there is no pin to report the stamp is a sentinel word rather than a version:
    /// `local-checkout` when the co-development workspace substitutes a local copy of the package,
    /// `unversioned` for a branch pin, `unreadable` or `unknown` when `Package.resolved` could not be
    /// read. Those are shown as-is bar the hyphen, on the same reasoning as `-dirty` above: on a test
    /// device it is information, not an error. Returns `nil` for a binary built without the phase.
    var libraryVersion: String? {
        guard let version = infoDictionary?["LibraryVersion"] as? String else { return nil }
        return version.replacingOccurrences(of: "-", with: " ") // "local-checkout" reads as prose
    }

    /// The package commit this binary was built against, shortened to 7 characters, e.g. `5813872`.
    ///
    /// Shown on its own row beside `libraryVersion`, mirroring how the app's own version and commit
    /// are shown. Returns `nil` when there is genuinely no commit to name — a local checkout, an
    /// unreadable `Package.resolved`, or a binary built without the phase — so the caller shows
    /// "N/A" rather than repeating the sentinel word on both rows.
    ///
    /// The two rows are independent on purpose: a branch pin records a real revision but no version,
    /// so this can be a commit while `libraryVersion` reads `unversioned`. A sentinel is stamped into
    /// *both* keys, hence the test that this one really is a hash — hex, and long enough that
    /// `prefix(7)` is not silently returning something shorter.
    var libraryCommit: String? {
        guard let revision = infoDictionary?["LibraryRevision"] as? String,
              revision.count >= 7, revision.allSatisfy(\.isHexDigit) else { return nil }
        return String(revision.prefix(7))
    }

    /// The date the package commit was made, e.g. `9 Aug 2026`, in the reader's own locale.
    ///
    /// The version and the sha say *which* library this is; this says *how old* it is, which is what
    /// separates a library that moved days before the release from one that has been stable for a
    /// year. Reads `LibraryCommitDate`, stamped from `git show -s --format=%cI` in the checkout
    /// SwiftPM resolved (vdhamer/Photo-Club-Hub#814).
    ///
    /// Unlike `buildDate` this really is ISO 8601, with a UTC offset, so it denotes an instant and is
    /// rendered here in the device's timezone rather than the committer's. Parsing also does the
    /// filtering: a sentinel word is not a date, so it falls out as `nil` and the caller shows "N/A".
    var libraryCommitDate: String? {
        guard let stored = infoDictionary?["LibraryCommitDate"] as? String,
              let date = ISO8601DateFormatter().date(from: stored) else { return nil }
        // Date only: this row answers "how old is the library", where a time adds nothing. The app's
        // own build row keeps its time, which is there to order several installs made on one day.
        // The cost is that a commit made near midnight can land on the previous day for a reader
        // west of the committer, since the instant is rendered in the reader's timezone.
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}
