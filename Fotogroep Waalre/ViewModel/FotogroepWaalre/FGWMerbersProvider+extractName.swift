//
//  FGWMerbersProvider+extractName.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 25/12/2022.
//

import Foundation
import RegexBuilder

extension FGWMembersProvider {

    struct PersonName {
        let fullName: String
        let givenName: String
        let familyName: String
    }

    func extractName(taggedString: String) -> PersonName {
        // <td>Bart van Stekelenburg</td>
        let nameCapture = Reference(Substring.self)
        let regex: Regex = Regex {
            "<td>"
            Capture(as: nameCapture) {
                OneOrMore(
                    CharacterClass(.anyOf("<").inverted)
                )
            }
            "</td>"
        }

        let fullName: String
        let givenName: String
        let familyName: String

        if let result = try? regex.firstMatch(in: taggedString) { // is a bit more robust than .wholeMatch
            fullName = String(result[nameCapture])
        } else {
            let error = "Bad name: \(taggedString)"
            print(error)
            fullName = error
        }

        (givenName, familyName) = componentizePersonName(name: fullName, printName: false)
        return PersonName(fullName: fullName, givenName: givenName, familyName: familyName)
    }

    // Split a String containing a name into PersonNameComponents
    // This is done manually instead of using the iOS 10
    // formatter.personNameComponents() function to handle last names like firstname=Henny lastname=Looren de Jong
    // An optional suffix like (lid), (aspirantlid) or (mentor) is removed
    // This is done in 2 stages using regular expressions because I coudn't get it to work in one stage

    func componentizePersonName(name: String, printName: Bool) -> (givenName: String, familyName: String) {
        var components = PersonNameComponents()
        var strippedNameString: String
        if name.contains(" (lid)") {
            let REGEX: String = "([^(]*) \\(lid\\).*"
            strippedNameString = name.capturedGroups(withRegex: REGEX)[0]
        } else if name.contains(" (aspirantlid)") {
            let REGEX: String = "([^(]*) \\(aspirantlid\\).*"
            strippedNameString = name.capturedGroups(withRegex: REGEX)[0]
        } else if name.contains(" (mentor)") {
            let REGEX: String = "([^(]*) \\(mentor\\).*"
            strippedNameString = name.capturedGroups(withRegex: REGEX)[0]
        } else {
            strippedNameString = name
        }
        let REGEX: String = "([^ ]+) (.*)" // split on first space
        let result = strippedNameString.capturedGroups(withRegex: REGEX)
        if result.count > 1 {
            components.givenName  = result[0]
            components.familyName = result[1]
            if printName {
                print("Name found: \(components.givenName!) \(components.familyName!)")
            }
            return (components.givenName!, components.familyName!)
        } else {
            if printName {
                print("Error in componentizePersonName() while handling \(name)")
            }
           return ("Bad member name: ", "rawNameString")
        }
    }

}
