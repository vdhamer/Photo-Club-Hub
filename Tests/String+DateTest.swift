//
//  String+DateTest.swift
//  Photo Club HubTests
//
//  Created by Peter van den Hamer on 20/07/2026.
//

import Foundation // for Calendar, TimeZone
import Testing
@testable import Photo_Club_Hub

@Suite("Tests String.extractDate()") struct StringExtractDateTests {

    // The test verifies that extractDate() is timezone-consistent (almost certainly by parsing in UTC/GMT), so a
    // date-only string always round-trips back to the same calendar day regardless of the device's locale.
    @Test("Valid ISO date returns correct Date without timezone drift") func validDateNoTimezoneDrift() throws {
        let date = try #require("2001-12-31".extractDate())
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "GMT")!
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        #expect(components.year == 2001)
        #expect(components.month == 12)
        #expect(components.day == 31)
    }

    @Test("Question mark returns nil") func questionMarkReturnsNil() {
        #expect("?".extractDate() == nil)
    }

    @Test("Empty string returns nil") func emptyStringReturnsNil() {
        #expect("".extractDate() == nil)
    }

    @Test("Malformed input returns nil and fires diagnostic") func malformedInputReturnsNil() {
        let spy = makeIfDebugFatalErrorSpy()
        installIfDebugFatalErrorSpy(spy)
        defer { removeIfDebugFatalErrorSpy() } // spy is process-global, so remove it promptly

        let result = "not-a-date".extractDate()

        #expect(result == nil)
        #expect(spy.messages.count == 1)
    }

}
