//
//  Level1HistoryTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 30/06/2026.
//

import Testing
@testable import Photo_Club_Hub

// Level1History is the loop/duplicate guard used by Level1JsonReader: each load of a level1.json file
// is recorded the first time it is visited.
// It can thereby guard that an Include tree (e.g. recursionA → recursionB → recursionA) cannot
// load the same file twice or recurse forever.
//
// These tests construct their OWN Level1History instances rather than touching the process-wide
// Level1JsonReader.level1History singleton, so they are fully isolated and deterministic.
//
// Level1History is annotated with @available(iOS 18, macOS 15, *). These tests are shared with the
// macOS-only Photo Club Hub HTML repo (which runs on a recent macOS release), but they also build for
// iOS, where the app supports iOS 17.x — an OS on which Level1History is unavailable. Each test is
// therefore gated with an `.enabled(if:)` condition trait so that on iOS 17 it is reported as
// *skipped* rather than as a silent pass. (Swift Testing's @Test/@Suite macros cannot be attached to
// @available declarations, so a trait is used instead.) The in-body `#available` guard is also needed to
// satisfy the compiler's use of Level1History; it is unreachable whenever the trait has enabled the test.
private let level1HistoryAvailable: Bool = {
    if #available(iOS 18, macOS 15, *) { true } else { false }
}()

@Suite("Tests the Level1History recursion/duplicate guard") struct Level1HistoryTests {

    // The first visit to a file finds "not yet visited"; the second visit to the SAME file is "visited".
    @Test("A file is unvisited the first time and visited the second time",
          .enabled(if: level1HistoryAvailable, "Level1History requires iOS 18 / macOS 15"))
    func recordsFirstVisit() {
        guard #available(iOS 18, macOS 15, *) else { return } // compiler-only; unreachable when enabled

        let history = Level1History()
        #expect(history.isVisited(fileName: "root") == false) // first encounter
        #expect(history.isVisited(fileName: "root") == true)  // already recorded
    }

    // Distinct file names are tracked independently — visiting one does not affect another.
    @Test("Different file names are tracked independently",
          .enabled(if: level1HistoryAvailable, "Level1History requires iOS 18 / macOS 15"))
    func distinctNamesAreIndependent() {
        guard #available(iOS 18, macOS 15, *) else { return } // compiler-only; unreachable when enabled

        let history = Level1History()
        #expect(history.isVisited(fileName: "fileA") == false)
        #expect(history.isVisited(fileName: "fileB") == false) // not affected by fileA
        #expect(history.isVisited(fileName: "fileA") == true)  // fileA is now known
        #expect(history.isVisited(fileName: "fileB") == true)  // fileB is now known
    }

    // clear() resets the guard: a previously visited file is considered unvisited again.
    @Test("clear() resets the visited history",
          .enabled(if: level1HistoryAvailable, "Level1History requires iOS 18 / macOS 15"))
    func clearResetsHistory() {
        guard #available(iOS 18, macOS 15, *) else { return } // compiler-only; unreachable when enabled

        let history = Level1History()
        #expect(history.isVisited(fileName: "museums") == false)
        #expect(history.isVisited(fileName: "museums") == true)

        history.clear()

        #expect(history.isVisited(fileName: "museums") == false) // all previous visits are cleared by clear()
    }

    // Matching is case-sensitive: names differing only in case are treated as different files.
    // (Documents current behaviour — file names in the Include tree are used verbatim.)
    @Test("File-name matching is case-sensitive",
          .enabled(if: level1HistoryAvailable, "Level1History requires iOS 18 / macOS 15"))
    func matchingIsCaseSensitive() {
        guard #available(iOS 18, macOS 15, *) else { return } // compiler-only; unreachable when enabled

        let history = Level1History()
        #expect(history.isVisited(fileName: "Museums") == false)
        #expect(history.isVisited(fileName: "museums") == false) // different case → different file
    }

}
