//
//  TownInInterfaceLanguageTest.swift
//  Photo Club HubTests
//
//  Created by Claude Code (guided by Peter van den Hamer) on 07/11/2026.
//

import Testing              // for testing macros
import CoreData             // for NSManagedObjectContext
import CoreLocation         // for CLLocationCoordinate2D
import Photo_Club_Hub_Data  // for PersistenceController, Organization, Language, LocalizedAddress
@testable import Photo_Club_Hub

// An organization's town is shown and searched in the interface language (#890, Data#88).
// The localized town comes from a `LocalizedAddress` row: Apple's name for the place at the coordinates, per language.
// These tests write such rows by hand, so no geocoder is involved.
@Suite("The town in the interface language: Maps search and Clubs section titles")
@MainActor
struct TownInInterfaceLanguageTests {

    private let context = PersistenceController(inMemory: true).container.viewContext

    init() {
        Language.initConstants(context: context) // creates the Language rows, including "en" and "nl"
    }

    /// The `Language` row for `isoCode`, which `initConstants` has created.
    private func language(_ isoCode: String) throws -> Language {
        try #require(Language.find(context: context, isoCode: isoCode))
    }

    /// Creates a club with the stored `town`, and a `LocalizedAddress` row in each of `localizedTowns`' languages.
    private func club(fullName: String, town: String, localizedTowns: [String: String] = [:]) throws -> Organization {
        let coordinates = CLLocationCoordinate2D(latitude: 51.0, longitude: 5.0)
        let organization = Organization.findCreateUpdate(
            context: context,
            organizationTypeEnum: OrganizationTypeEnum.club,
            idPlus: OrganizationIdPlus(fullName: fullName, town: town, nickname: "Test"),
            coordinates: coordinates,
            optionalFields: OrganizationOptionalFields()
        )
        for (isoCode, localizedTown) in localizedTowns {
            _ = LocalizedAddress.findCreateUpdate(
                bgContext: context,
                organization: organization,
                language: try language(isoCode),
                newLocalizedAddressFields: LocalizedAddressFields(localizedTown: localizedTown,
                                                                  localizedCountry: "Country"),
                newCoordinates: coordinates
            )
        }
        try context.save()
        return organization
    }

    // MARK: - Maps search

    @Test("The localized town is found in the interface language only")
    func localizedTownMatches() throws {
        let museum = try club(fullName: "Museum Ludwig", town: "Köln",
                              localizedTowns: ["nl": "Keulen", "en": "Cologne"])
        #expect(FilteredMapsView.matches(museum, searchText: "Keulen", language: try language("nl")))
        #expect(FilteredMapsView.matches(museum, searchText: "cologne", language: try language("en")))
        #expect(!FilteredMapsView.matches(museum, searchText: "Keulen", language: try language("en")))
    }

    @Test("The stored town and the name are found in every language, and without one")
    func storedTownAndNameMatch() throws {
        let museum = try club(fullName: "Museum Ludwig", town: "Köln", localizedTowns: ["nl": "Keulen"])
        #expect(FilteredMapsView.matches(museum, searchText: "Köln", language: try language("nl")))
        #expect(FilteredMapsView.matches(museum, searchText: "Köln", language: nil))
        #expect(FilteredMapsView.matches(museum, searchText: "Ludwig", language: nil))
        #expect(!FilteredMapsView.matches(museum, searchText: "Keulen", language: nil)) // Language table not seeded
    }

    @Test("Apple's non-breaking hyphen matches an ordinary hyphen typed by the user")
    func nonBreakingHyphenMatches() throws {
        let club = try club(fullName: "Fotogroep Argus", town: "Den Bosch",
                            localizedTowns: ["nl": "'s\u{2011}Hertogenbosch"])
        #expect(FilteredMapsView.matches(club, searchText: "'s-Hertogenbosch", language: try language("nl")))
        #expect(FilteredMapsView.matches(club, searchText: "Den Bosch", language: try language("nl")))
    }

    @Test("The \"Town?\" placeholder is found, as the card shows it, so maintainers can list the gaps")
    func placeholderMatches() throws {
        let museum = try club(fullName: "Lianzhou Museum of Photography", town: "Lianzhou",
                              localizedTowns: ["nl": LocalizedAddress.unknownTown])
        let other = try club(fullName: "Fotogroep de Gender", town: "Eindhoven", localizedTowns: ["nl": "Eindhoven"])
        #expect(FilteredMapsView.matches(museum, searchText: "Town?", language: try language("nl")))
        #expect(!FilteredMapsView.matches(other, searchText: "Town?", language: try language("nl")))
        #expect(FilteredMapsView.matches(museum, searchText: "Lianzhou", language: try language("nl")))
    }

    // MARK: - Clubs section titles

    @Test("A club whose name contains its town gets no town")
    func nameContainsTown() throws {
        let club = try club(fullName: "Fotogroep Waalre", town: "Waalre", localizedTowns: ["nl": "Waalre"])
        let title = FilteredMemberPortfoliosView.sectionTitle(for: club, language: try language("nl"))
        #expect(title.name == "Fotogroep Waalre")
        #expect(title.town == nil)
    }

    @Test("The town is the localized one, apart from the name")
    func localizedTownApart() throws {
        let museum = try club(fullName: "Museum Ludwig", town: "Köln", localizedTowns: ["nl": "Keulen"])
        let title = FilteredMemberPortfoliosView.sectionTitle(for: museum, language: try language("nl"))
        #expect(title.name == "Museum Ludwig")
        #expect(title.town == "Keulen")
    }

    @Test("Without a localized row, the stored town is used")
    func storedTownWithoutRow() throws {
        let club = try club(fullName: "Fotogroep de Gender", town: "Eindhoven")
        let title = FilteredMemberPortfoliosView.sectionTitle(for: club, language: try language("en"))
        #expect(title.name == "Fotogroep de Gender")
        #expect(title.town == "Eindhoven")
    }

    @Test("Parentheses inside Apple's town stay in the town", arguments: ["en", "nl"])
    func parenthesesInTown(isoCode: String) throws {
        let club = try club(fullName: "Shooters Fotoclub", town: "Beuningen",
                            localizedTowns: ["en": "Beuningen (Gld)", "nl": "Beuningen (Gld)"])
        let title = FilteredMemberPortfoliosView.sectionTitle(for: club, language: try language(isoCode))
        #expect(title.name == "Shooters Fotoclub")
        #expect(title.town == "Beuningen (Gld)")
    }

    @Test("Parentheses inside the name stay in the name")
    func parenthesesInName() throws {
        let club = try club(fullName: "Fotogroep Test (FGT)", town: "Eindhoven", localizedTowns: ["en": "Eindhoven"])
        let title = FilteredMemberPortfoliosView.sectionTitle(for: club, language: try language("en"))
        #expect(title.name == "Fotogroep Test (FGT)")
        #expect(title.town == "Eindhoven")
    }

    // MARK: - The interface language

    @Test("The interface-language request is usable by @FetchRequest and finds one supported language")
    func interfaceLanguageRequest() throws {
        let request = Language.interfaceLanguageRequest
        #expect(request.sortDescriptors != nil) // @FetchRequest traps on nil sortDescriptors
        #expect(request.fetchLimit == 1)
        let languages = try context.fetch(request)
        #expect(languages.count == 1)
        #expect(["en", "nl"].contains(languages.first?.isoCode)) // knownRegions: the test host runs in one of these
    }

}
