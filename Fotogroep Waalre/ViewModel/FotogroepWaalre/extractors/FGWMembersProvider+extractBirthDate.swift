//
//  FGWMembersProvider+extractBirthDate.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 26/12/2022.
//

import Foundation // for Date
import RegexBuilder

extension FGWMembersProvider {

    func extractBirthDate(taggedString: String) -> Date? {
        // <td>2022-05-26</td> is valid input

        let REGEX: String = "<td>(.*)</td>"
        let result = taggedString.capturedGroups(withRegex: REGEX)
        guard result.count > 0 else {
            fatalError("Failed to decode data from \(taggedString) because RegEx didn't trigger")
        }

        let strategy = Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
                                          timeZone: TimeZone.autoupdatingCurrent)
        let birthDateString = result[0]
        let date = try? Date(birthDateString, strategy: strategy) // can be nil
        if date==nil && !birthDateString.isEmpty {
            print("Failed to decode data from \"\(result[0])\" because the date is not in ISO8601 format")
        }
        return date
    }

}
