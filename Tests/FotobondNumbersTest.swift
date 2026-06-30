//
//  FotobondNumbersTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 30/06/2026.
//

import Testing
@testable import Photo_Club_Hub

@Suite("Tests FotobondClubNumber & FotobondMemberNumber display formatting") struct FotobondNumbersTests {

    // MARK: - FotobondClubNumber

    // Notation
    // The convention here is exclusive to the Dutch www.fotobond.nl organisation.
    // But I added a extra "." and the Pers. notation for new personal membership were added for readability.
    //   DD   - 2 digits representing Department/Afdeling
    //   CC   - 2 digit Club number (within the Division)

    // Normal case: DDCC splits into DD.CC - here no leading zero padding.
    @Test("Club number 1610 formats as 16.10") func clubNumberNormal() throws {
        let club = try #require(FotobondClubNumber(id: 1610))
        #expect(club.display == "16.10")
    }

    // A club number ending in 00 represents the department's "personal" group, shown as "Pers".
    @Test("Club number 1600 formats as 16.Pers") func clubNumberPersonal() throws {
        let club = try #require(FotobondClubNumber(id: 1600))
        #expect(club.display == "16.Pers")
    }

    // A regular low club number is zero-padded on both parts of the identifier.
    @Test("Club number 301 formats as 03.01") func clubNumberLowPadded() throws {
        let club = try #require(FotobondClubNumber(id: 301))
        #expect(club.display == "03.01")
    }

    // The failable FotobondClubNumber(id:) initializer returns nil when no number is available.
    @Test("Club number nil id produces no instance") func clubNumberNil() {
        #expect(FotobondClubNumber(id: nil) == nil)
    }

    // MARK: - FotobondMemberNumber

    // Notation
    // The convention here is exclusive to the Dutch www.fotobond.nl organisation.
    // But I added a extra "." and the Pers. notation for new personal membership were added for readability.
    //   DD   - 2 digits representing Department/Afdeling
    //   CC   - 2 digit Club number (within the Division)
    //   MMM  - 3 digit Member number (within a normal club)
    //   MMMM - 4 digit Member number (for personal memberships that don't fall under a normal club)

    // Normal case: DDCCMMM splits into DD.CC.MMM.
    @Test("Member number 1610123 formats as 16.10.123") func memberNumberNormal() throws {
        let member = try #require(FotobondMemberNumber(id: 1610123))
        #expect(member.display == "16.10.123")
    }

    // The 3_000_000 department is a special "personal" case rendered as Pers.MMMM.
    @Test("Member number 3004321 formats as Pers.4321") func memberNumberPersonal() throws {
        let member = try #require(FotobondMemberNumber(id: 3004321))
        #expect(member.display == "Pers.4321")
    }

    // Drenthe-Vechtdal example: low department/club numbers stay zero-padded.
    @Test("Member number 304123 formats as 03.04.123") func memberNumberLowPadded() throws {
        let member = try #require(FotobondMemberNumber(id: 304123))
        #expect(member.display == "03.04.123")
    }

    // The failable initializer returns nil when no number is available.
    @Test("Member number nil id produces no instance") func memberNumberNil() {
        #expect(FotobondMemberNumber(id: nil) == nil)
    }

}
