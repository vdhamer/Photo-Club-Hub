//
//  FGWMerbersProvider+extractName.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 25/12/2022.
//

import Foundation // for PersonNameComponents
import RegexBuilder

extension FGWMembersProvider {

    struct PersonName {
        let fullName: String
        let givenName: String
        let familyName: String
    }

    func extractName(taggedString: String) -> PersonName {
        // "<td>José Daniëls</td>"
        // "<td>Bart van Stekelenburg (lid)</td>"
        // "<td>Zoë Aspirant (aspirantlid)</td>"
        // "<td>Hans Zoete (mentor)</td>"
        let regex = Regex {
            "<td>"
            Capture {
                OneOrMore(.any, .reluctant)
            }
            "</td>"
        }

        let fullName: String
        if let match = try? regex.firstMatch(in: taggedString) { // is a bit more robust than .wholeMatch
            let (_, name) = match.output
            fullName = String(name)
        } else {
            let error = "Bad name: \(taggedString)"
            print(error)
            fullName = error
        }

        let givenName: String
        let familyName: String
        (givenName, familyName) = componentizePersonName(name: fullName, printName: false)
        return PersonName(fullName: fullName, givenName: givenName, familyName: familyName)
    }

    // Split a String containing a name into PersonNameComponents
    // This is done manually instead of using the iOS 10
    // formatter.personNameComponents() function to handle last names like firstname=Henny lastname=Looren de Jong
    // An optional suffix like (lid), (aspirantlid) or (mentor) is removed
    // This is done in 2 stages using regular expressions because I coudn't get it to work in one stage

    func componentizePersonName(name: String, printName: Bool) -> (givenName: String, familyName: String) {
        // "José Daniëls" -> ("José","Daniëls") former member
        // "Bart van Stekelenburg (lid)" -> ("Bart","van Steklenburg") member
        // "Zoë Aspirant (aspirantlid)" -> ("Zoë","Aspirant") aspiring member
        // "Hans Zoete (mentor)" -> ("Hans","Zoete") coach
        let regex = Regex {
            Capture {
                OneOrMore(.any, .reluctant) // reluctant prevents capturing the " "
            } transform: { givenName in String(givenName) }
            " "
            Capture {
                OneOrMore(.any, .reluctant)
            } transform: { familyName in String(familyName) } // reluctant prevents capturing the optional ChoiceOf
            Optionally {
                ChoiceOf {
                    " (lid)" // NL
                    " (member)" // EN
                    " (aspirantlid)" // NL
                    " (aspiring)" // EN
                    " (mentor)" // NL
                    " (coach)" // EN
                }
            }
        }

        if let match = try? regex.wholeMatch(in: name) { // is a bit more robust than .wholeMatch
            let (_, givenName, familyName) = match.output
            if printName {
                print("Name found: \(givenName) \(familyName)")
            }
            return (givenName, familyName)
        } else {
            print("Error: problem in componentizePersonName() <\(name)>")
            return ("errorInGivenName", "errorInFamilyName")
        }
    }

}
