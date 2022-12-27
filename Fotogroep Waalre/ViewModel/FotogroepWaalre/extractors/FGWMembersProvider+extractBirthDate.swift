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
//        let regex_old: Regex = /"<td>(.*)</td>"/

        let birthDate: String

        let regex = Regex {
            "<td>"
            Capture {
                ZeroOrMore(.any, .reluctant)
            }
            "</td>"
        }

        if let match = try? regex.wholeMatch(in: taggedString) {
            let (_, dateString) = match.output
            birthDate = String(dateString)
        } else {
            fatalError("Failed to decode date from \(taggedString) because RegEx didn't trigger")
        }

        let strategy = Date.ParseStrategy(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
                                          timeZone: TimeZone.autoupdatingCurrent)
        let date = try? Date(birthDate, strategy: strategy) // can be nil
        if date==nil && !birthDate.isEmpty {
            print("Failed to decode data from \"\(birthDate)\" because the date is not in ISO8601 format")
        }
        return date
    }

    func extractBirthDate_old(taggedString: String) -> Date? { // TODO: remove
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
