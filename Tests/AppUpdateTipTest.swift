//
//  AppUpdateTipTest.swift
//  Photo Club HubTests
//
//  Created by Claude Code (guided by Peter van den Hamer) on 25/11/2026.
//

import Testing              // for testing macros and framework
import Foundation           // for URL and FileManager
import CoreData             // for NSMergePolicy
import Photo_Club_Hub_Data  // for LevelLoader, NewerPackageRequest and PersistenceController
@testable import Photo_Club_Hub

// The tip that asks users to update the app when the club data needs a newer app release (#899).
// `LevelLoader.newerPackageRequest` is process-wide, so the load tests run serially. No other suite of this test
// target runs a load pass, so nothing else can overwrite it between a load and its check.
@MainActor @Suite("Tests the tip asking users to update because the club data needs a newer app", .serialized)
struct AppUpdateTipTests {

    @Test("The tip's intrnal id names the app version and the month, so each version and each month gets a fresh tip")
    func idNamesAppVersionAndMonth() throws {
        let calendar = Calendar(identifier: .gregorian)
        let lastDayOfNovember = try #require(calendar.date(from: DateComponents(year: 2026, month: 11, day: 30)))
        let firstDayOfDecember = try #require(calendar.date(from: DateComponents(year: 2026, month: 12, day: 1)))
        let lastDayOfDecember = try #require(calendar.date(from: DateComponents(year: 2026, month: 12, day: 31)))

        #expect(AppUpdateTip.id(appVersion: "3.0.5", date: lastDayOfNovember) == "AppUpdateTip-3.0.5-2026-11")
        #expect(AppUpdateTip.id(appVersion: "3.0.5", date: firstDayOfDecember) == "AppUpdateTip-3.0.5-2026-12")
        #expect(AppUpdateTip.id(appVersion: "3.0.5", date: lastDayOfDecember) == "AppUpdateTip-3.0.5-2026-12")
        #expect(AppUpdateTip.id(appVersion: "3.0.6", date: lastDayOfDecember) == "AppUpdateTip-3.0.6-2026-12")
        #expect(AppUpdateTip().id == AppUpdateTip.id(appVersion: Bundle.main.shortVersion, date: .now))
    }

    // MARK: - With the Data package of this build

    // What `ClubLoadCoordinator` sets `AppUpdateTip.dataNeedsNewerApp` from, checked through the Data package version
    // that this app pins.

    // Loads a Level 1 root written by the test, the way the `-level1RootURL` launch argument makes the app do,
    // and returns the pass's `LevelLoader.newerPackageRequest`. `minimumVersion` nil leaves the header field out.
    private func loadRoot(minimumVersion: String?) async throws -> NewerPackageRequest? {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }

        let rootURL = folder.appendingPathComponent("appUpdateTipTest.level1.json")
        let minimumVersionLine = minimumVersion.map { "\"minimumDataPackageVersion\": \"\($0)\"," } ?? ""
        let json = """
                   {
                       "level1Header": {
                           \(minimumVersionLine)
                           "level1URL": "\(rootURL.absoluteString)"
                       },
                       "clubs": [
                           {
                               "idPlus": { "town": "Test Valley", "fullName": "Update Tip Club",
                                           "nickName": "UpdateTip" },
                               "coordinates": { "latitude": 51.12862, "longitude": 1.51063 }
                           }
                       ]
                   }
                   """
        try json.write(to: rootURL, atomically: true, encoding: .utf8)

        let persistenceController = PersistenceController(inMemory: true)
        let viewContext = persistenceController.container.viewContext
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        Language.initConstants(context: viewContext)
        OrganizationType.initConstants(context: viewContext)

        // useOnlyInBundleFile stays false: a custom root has no bundled copy, so it is only read from its URL.
        await LevelLoader.loadAllLevels(usedContainer: persistenceController.container,
                                        isBeingTested: true,
                                        level1RootURL: rootURL)
        return LevelLoader.newerPackageRequest
    }

    @Test("A root asking for a far newer Data package is reported, with its file name and version")
    func highMinimumVersionIsReported() async throws {
        let request = try await loadRoot(minimumVersion: "99.0.0")

        #expect(request?.fileName == "appUpdateTipTest")
        #expect(request?.minimumVersion == "99.0.0")
    }

    @Test("A root asking for an older Data package, or for none, is not reported", arguments: ["1.0.0", nil])
    func normalRootIsNotReported(minimumVersion: String?) async throws {
        #expect(try await loadRoot(minimumVersion: minimumVersion) == nil)
    }

}
