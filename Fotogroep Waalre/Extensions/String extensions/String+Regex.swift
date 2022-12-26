//
//  FoundationExtensions.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 26/12/2021.
//

import Foundation
import CoreLocation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension NSPredicate {
    static var all = NSPredicate(format: "TRUEPREDICATE")
    static var none = NSPredicate(format: "FALSEPREDICATE")
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        (lhs.longitude == rhs.longitude) && (lhs.latitude == rhs.latitude)
    }
}

///////////////////////////////////////////////////////////////////////////////////////////
// MARK: - add regular expression support to String class
//
// http://samwize.com/2016/07/21/how-to-capture-multiple-groups-in-a-regex-with-swift/
// "abcdefg".capturedGroups(withRegex: "a(.*)f") will match "bcde"

extension String { // TODO: remove
    func capturedGroups(withRegex pattern: String) -> [String] {
        var results = [String]()

        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [])
        } catch {
            return results
        }

        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))

        guard let match = matches.first else { return results }

        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return results }

        for index in 1...lastRangeIndex {
            let capturedGroupIndex = match.range(at: index)
            let matchedString = (self as NSString).substring(with: capturedGroupIndex)
            results.append(matchedString)
        }

        return results
    }
}
