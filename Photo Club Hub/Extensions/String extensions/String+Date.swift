//
//  String+Date.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 20/07/2024.
//

import Foundation // for Date
import RegexBuilder // for Regex

extension String {

    // "2001-12-31" returns Dec 31st 2001
    // "?" returns nil
    public func extractDate() -> Date? {
        guard self.isEmpty == false else {
            return nil
        }
        let date: Date?

        let regex = Regex {
            ChoiceOf {
                One("?") // can probably be made stricter: <td>?2001-12-31</td> is currently interpreted as 2001-12-31
                Capture(.date(format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
                              locale: Locale.autoupdatingCurrent,
                              timeZone: TimeZone.gmt))
                              // timeZone prevents 2001-12-31 from becoming 2001-12-30 23:00:00 UTC
            }
        }

        if let match = try? regex.wholeMatch(in: self) {
            let (_, capturedDate) = match.output
            date = capturedDate
        } else {
            ifDebugFatalError("Failed to decode date from \(self) because RegEx didn't trigger",
                              file: #fileID, line: #line) // likely deprecation of #fileID in Swift 6.0
            return nil // in release mode, a bad date is returned as nil and the app doesn't stop.
        }

        return date
    }

}
