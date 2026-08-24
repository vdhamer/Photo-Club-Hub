//
//  PackageResourceResolutionTest.swift
//  Photo Club HubTests
//
//  Created by Claude Code (guided by Peter van den Hamer) on 02/08/2026.
//

import Testing
import Foundation
import CoreData // for NSManagedObjectModel
import Photo_Club_Hub_Data // for PersistenceController

// #769 step 8(b): the shipping .app must resolve the package's JSON, .momd and .xcstrings from its
// own bundle context. Since step 3 removed those resources from the app target, the only remaining
// copies live inside the package's resource bundle nested in the .app. If SwiftPM ever stopped
// embedding that bundle, the app would build cleanly and then fail at runtime.
//
// The bundle is deliberately located by name from Bundle.main rather than through the package's own
// Bundle.module accessor: that is what "resolves from the shipping .app's bundle context" means, and
// it fails loudly if the resource bundle is missing from the app rather than silently falling back.
@Suite("Tests that the app resolves the package's bundled resources")
struct PackageResourceResolutionTests {

    // Name SwiftPM gives the resource bundle: "<package name>_<target name>.bundle", spaces preserved.
    private static let resourceBundleName = "Photo Club Hub Data_Photo Club Hub Data"

    private func packageBundle() throws -> Bundle {
        let url = try #require(Bundle.main.url(forResource: Self.resourceBundleName, withExtension: "bundle"),
                               "\(Self.resourceBundleName).bundle is not embedded in the .app")
        return try #require(Bundle(url: url), "Could not open \(Self.resourceBundleName).bundle")
    }

    @Test("The package's resource bundle is embedded in the app")
    func resourceBundleIsEmbedded() throws {
        _ = try packageBundle()
    }

    @Test("Level 0 JSON resolves from the package bundle")
    func level0JsonResolves() throws {
        let bundle = try packageBundle()
        #expect(bundle.url(forResource: "root", withExtension: "level0.json") != nil,
                "root.level0.json missing: the offline fallback and the expertise/language list would be gone")
    }

    @Test("The compiled Core Data model resolves from the package bundle")
    func compiledModelResolves() throws {
        let bundle = try packageBundle()
        let momd = try #require(bundle.url(forResource: "Photo_Club_Hub", withExtension: "momd"),
                                "Photo_Club_Hub.momd missing: PersistenceController would fatalError at launch")
        let model = try #require(NSManagedObjectModel(contentsOf: momd), "Could not load the model")
        // Spot-check a few entities so a truncated or stale model is caught, not just a present file.
        for entity in ["Organization", "Photographer", "MemberPortfolio", "Language", "Expertise"] {
            #expect(model.entitiesByName[entity] != nil, "Entity \(entity) missing from the compiled model")
        }
    }

    @Test("The package's string catalog resolves from the package bundle")
    func stringCatalogResolves() throws {
        let bundle = try packageBundle()
        // localizedString(forKey:value:table:) returns `value` when the key cannot be found, so a
        // distinctive sentinel distinguishes "table resolved" from "fell back". Comparing against the
        // key itself would not: most English values are identical to their keys.
        let sentinel = "⟪unresolved⟫"
        let resolved = bundle.localizedString(forKey: "member", value: sentinel, table: "PhotoClubHubData")
        #expect(resolved != sentinel, "PhotoClubHubData.strings did not resolve from the package bundle")
    }

    @Test("PersistenceController loads the model without falling back to the main bundle")
    func persistenceControllerUsesPackageModel() {
        // PersistenceController fatalErrors if it cannot find the .momd via Bundle.module, so reaching
        // the assertion at all is part of the check. The entity spot-check then confirms it loaded the
        // package's model rather than some other model that happens to be present.
        let controller = PersistenceController(inMemory: true)
        let model = controller.container.managedObjectModel
        #expect(model.entitiesByName["Organization"] != nil)
        #expect(model.entitiesByName["Language"] != nil)
    }
}
