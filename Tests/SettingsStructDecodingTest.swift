//
//  SettingsStructDecodingTest.swift
//  Photo Club HubTests
//
//  Created by Claude Code (guided by Peter van den Hamer) on 23/11/2026.
//

import Testing
import Foundation // for JSONEncoder, JSONDecoder, JSONSerialization
@testable import Photo_Club_Hub

// The settings are stored as one JSON blob in UserDefaults.
// Each field is decoded on its own, so that a blob written by an older version (without a newly added key)
// or holding a value this version can't read keeps all its other settings (#892).
@Suite("Stored settings survive a missing or unreadable field")
struct SettingsStructDecodingTests {

    /// Settings that differ from `SettingsStruct.defaultValue` in every field that a 3.0.4 blob holds,
    /// so that a field silently falling back to its default makes a test fail.
    /// The memberwise initializer doesn't run `didSet`, so the toggle couplings don't interfere
    /// (and no open/close sound plays).
    private static let nonDefault = SettingsStruct(
        showCurrentMembers: false,
        showOfficers: true,
        showAspiringMembers: false,
        showHonoraryMembers: false,
        showFormerMembers: true,
        showDeceasedMembers: false,
        showExternalCoaches: true,
        preferenceForFeaturedImage: false,
        showClubs: false,
        showMuseums: false,
        showInactiveOrganizations: false, // the one field a 3.0.4 blob doesn't have
        highlightFotobondNL: true,
        highlightNonFotobondNL: true,
        highlightColor: .blue
    )

    /// The JSON of `settings` as a dictionary, so a test can remove or replace a key.
    private func jsonObject(_ settings: SettingsStruct) throws -> [String: Any] {
        let data = try JSONEncoder().encode(settings)
        return try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    }

    private func decode(_ object: [String: Any]) throws -> SettingsStruct {
        let data = try JSONSerialization.data(withJSONObject: object)
        return try JSONDecoder().decode(SettingsStruct.self, from: data)
    }

    @Test("Encoding and decoding gives back the same settings")
    func roundTrip() throws {
        var settings = Self.nonDefault
        settings.showInactiveOrganizations = true
        let decoded = try JSONDecoder().decode(SettingsStruct.self, from: JSONEncoder().encode(settings))
        #expect(decoded == settings)
    }

    @Test("A blob without showInactiveOrganizations, as 3.0.4 stored it, keeps its other values")
    func blobFromVersion304() throws {
        var object = try jsonObject(Self.nonDefault)
        object.removeValue(forKey: "showInactiveOrganizations")
        let decoded = try decode(object)
        #expect(decoded == Self.nonDefault)
        #expect(decoded.showInactiveOrganizations == false)
    }

    @Test("An unknown highlightColor falls back to the default color, and only that field does")
    func unknownHighlightColor() throws {
        var object = try jsonObject(Self.nonDefault)
        object["highlightColor"] = "noSuchColor"
        let decoded = try decode(object)

        var expected = Self.nonDefault
        expected.highlightColor = SettingsStruct.defaultValue.highlightColor
        #expect(decoded == expected)
    }

    @Test("A field of the wrong type falls back to its default, and only that field does")
    func wrongType() throws {
        var object = try jsonObject(Self.nonDefault)
        object["showClubs"] = "yes"
        let decoded = try decode(object)

        var expected = Self.nonDefault
        expected.showClubs = SettingsStruct.defaultValue.showClubs
        #expect(decoded == expected)
    }

    @Test("An empty blob gives the default settings")
    func emptyBlob() throws {
        #expect(try decode([:]) == SettingsStruct.defaultValue)
    }

}
