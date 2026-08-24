//
//  BuildStampFileTest.swift
//  Photo Club HubTests
//
//  Created by Claude Code under guidance of Peter van den Hamer on 22/08/2026.
//

import Testing
import Foundation
@testable import Photo_Club_Hub

// The five build stamps were previously written into the built Info.plist, a file Xcode owns and
// regenerates whenever it likes. On an incremental build that regeneration lands just after the
// stamping phase, so the stamps reached neither the signed app nor the iOS Settings pane, which fell
// back to its "?" placeholders. A clean build happened to produce the inverse results, which is what
// made it look intermittent.
//
// They now live in a file, `BuildStamp`, that nothing else produces (#822). These tests are
// what notices if they ever go missing, since nothing else would notice:
// the app keeps running and the Settings pane just quietly shows placeholders.
@Suite("Checks that the build stamps survive into the built app")
struct BuildStampFileTests {

    /// Every stamp the *Run GateAndStamp script* build phase is expected to write.
    private static let stampKeys = ["GitCommitHash",
                                    "BuildDate",
                                    "LibraryVersion",
                                    "LibraryRevision",
                                    "LibraryCommitDate"]

    /// `BuildStamp.plist` as it sits in the app bundle under test.
    private static func buildStamps() throws -> [String: String] {
        let url = try #require(Bundle.main.url(forResource: "BuildStamp", withExtension: "plist"),
                               """
                               No BuildStamp.plist in the app bundle — did the "Run GateAndStamp \
                               script" build phase actually run, and did it still write this file?
                               """)
        let plist = try PropertyListSerialization.propertyList(from: Data(contentsOf: url),
                                                               options: [],
                                                               format: nil)
        return try #require(plist as? [String: String], "BuildStamp.plist is not a dictionary of strings")
    }

    @Test("BuildStamp.plist carries every stamp")
    func buildStampFileCarriesEveryStamp() throws {
        let stamps = try Self.buildStamps()
        for key in Self.stampKeys {
            #expect(stamps[key] != nil, "BuildStamp.plist has no '\(key)'")
        }
    }

    @Test("No stamp is blank or contains a space")
    func stampsHonorTheFormatContract() throws {
        let stamps = try Self.buildStamps()
        for key in Self.stampKeys {
            let value = stamps[key] ?? ""
            #expect(value.isEmpty == false, "'\(key)' is blank: the script should stamp a word instead")
            #expect(value.contains(" ") == false,
                    "'\(key)' is '\(value)', and a stamped value never contains a space (#807)")
        }
    }

    // Only the two stamps that are always a real value are asserted here. The three library ones are
    // allowed to be sentinel words: a local checkout or a branch pin has no version or revision to
    // report, and the displaying rows say so rather than pretending otherwise.
    @Test("The app's own stamps read back as a commit and a date")
    func appStampsAreReadableByTheBundleExtension() throws {
        let commit = try #require(Bundle.main.gitCommit, "Bundle.gitCommit is nil despite a stamp file")
        let hash = commit.hasSuffix("-dirty") ? String(commit.dropLast("-dirty".count)) : commit
        let isHexadecimal = hash.allSatisfy(\.isHexDigit) // bound first: #expect cannot take a rethrows call
        #expect(hash.count == 7, "'\(commit)' should shorten to the 7 characters GitHub shows")
        #expect(isHexadecimal, "'\(commit)' is not a commit hash")

        #expect(Bundle.main.buildDate != nil, "Bundle.buildDate is nil despite a stamp file")
        #expect(Bundle.main.libraryVersion != nil, "Bundle.libraryVersion is nil despite a stamp file")
    }

    // Guards the decision rather than the symptom: putting these back into Info.plist reintroduces
    // #822, and the app would keep building and keep showing placeholders.
    @Test("The stamps stay out of Info.plist, which Xcode may rewrite at will")
    func stampsAreNotWrittenIntoInfoPlist() {
        for key in Self.stampKeys {
            #expect(Bundle.main.infoDictionary?[key] == nil,
                    "'\(key)' is back in Info.plist, where an incremental build can discard it (#822)")
        }
    }
}
