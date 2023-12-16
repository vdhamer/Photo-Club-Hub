//
//  FGWMembersProvider+extractBirthDate.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/12/2022.
//

import Foundation // for Date
import RegexBuilder

extension FotogroepWaalreMembersProvider {

    func extractBirthDate(taggedString: String) -> Date? {
        // <td>2001-12-31</td> is Dec 31st 2001
        // <td>?</td> means birthdate is unavailableba

        let birthDate: Date?
        let regex = Regex {
            "<td>"
            ChoiceOf {
                One("?") // can probably be made stricter: <td>?2001-12-31</td> is interpreted as 2001-12-31
                Capture(.date(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
                              locale: Locale.autoupdatingCurrent,
                              timeZone: TimeZone.autoupdatingCurrent))
            }
            "</td>"
        }

        if let match = try? regex.wholeMatch(in: taggedString) {
            let (_, date) = match.output
            birthDate = date
        } else {
            ifDebugFatalError("Failed to decode date from \(taggedString) because RegEx didn't trigger",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            birthDate = Date() // in release mode, a bad date is replaced by today's date. And the app doesn't stop.
        }

        return birthDate
    }

}
