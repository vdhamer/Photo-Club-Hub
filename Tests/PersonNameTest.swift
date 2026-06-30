//
//  PersonNameTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 30/06/2026.
//

import Testing
@testable import Photo_Club_Hub

@Suite("Tests the PersonName value type") struct PersonNameTests {

    // MARK: - Synthesizing the full name when none is supplied

    // Without an infix, the full name is simply "given family".
    @Test("Full name synthesized without infix") func synthesizeWithoutInfix() {
        let name = PersonName(givenName: "John", infixName: "", familyName: "Doe")
        #expect(name.fullNameWithParenthesizedRole == "John Doe")
        #expect(name.fullNameWithoutParenthesizedRole == "John Doe")
    }

    // With an infix, it is inserted between the given and family names.
    @Test("Full name synthesized with infix") func synthesizeWithInfix() {
        let name = PersonName(givenName: "Jan", infixName: "van", familyName: "Doesburg")
        #expect(name.fullNameWithParenthesizedRole == "Jan van Doesburg")
        #expect(name.fullNameWithoutParenthesizedRole == "Jan van Doesburg")
    }

    // An explicitly supplied full name is used verbatim rather than being synthesized.
    @Test("Explicit full name overrides synthesis") func explicitFullNameUsed() {
        let name = PersonName(fullNameWithParenthesizedRole: "Bart van Stekelenburg (lid)",
                              givenName: "Bart", infixName: "van", familyName: "Stekelenburg")
        #expect(name.fullNameWithParenthesizedRole == "Bart van Stekelenburg (lid)")
    }

    // MARK: - Stripping a parenthesized role

    // A "(lid)" role suffix is removed, leaving the infix-containing name intact.
    @Test("Parenthesized role (lid) is stripped") func stripMemberRole() {
        let name = PersonName(fullNameWithParenthesizedRole: "Bart van Stekelenburg (lid)",
                              givenName: "Bart", infixName: "van", familyName: "Stekelenburg")
        #expect(name.fullNameWithoutParenthesizedRole == "Bart van Stekelenburg")
    }

    // A "(aspirantlid)" role suffix is removed; accented characters are preserved.
    @Test("Parenthesized role (aspirantlid) is stripped") func stripAspiringRole() {
        let name = PersonName(fullNameWithParenthesizedRole: "Zoë Aspirant (aspirantlid)",
                              givenName: "Zoë", infixName: "", familyName: "Aspirant")
        #expect(name.fullNameWithoutParenthesizedRole == "Zoë Aspirant")
    }

    // A name without any parenthesized role is returned unchanged, accents and all.
    @Test("Name without a role is unchanged") func nameWithoutRoleUnchanged() {
        let name = PersonName(fullNameWithParenthesizedRole: "José Daniëls",
                              givenName: "José", infixName: "", familyName: "Daniëls")
        #expect(name.fullNameWithoutParenthesizedRole == "José Daniëls")
    }

}
