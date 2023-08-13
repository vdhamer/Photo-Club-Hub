//
//  FGWMerbersProvider+extractName.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 25/12/2022.
//

import RegexBuilder

extension FotogroepWaalreMembersProvider {

    struct PersonName {
        let fullName: String // "John Doe" or "Jan van Doesburg"
        let givenName: String // "John" or "Jan"
        let infixName: String // "" or "van"
        let familyName: String // "Doe" or "Doesburg"
    }

    func extractName(taggedString: String) -> PersonName {
        let fullName = removeTags(taggedString: taggedString)
        return componentizePersonName(fullName: fullName, printName: false)
    }

    // Returns fullName String by stripping off certain HTML tags

    private func removeTags(taggedString: String) -> String {
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

        if let match = try? regex.firstMatch(in: taggedString) { // is a bit more robust than .wholeMatch
            let (_, name) = match.output
            return String(name)
        } else {
            let error = "Badly tagged name: \(taggedString)"
            print(error)
            return error
        }
    }

    // Split a String containing a name into PersonNameComponents
    // This is done manually instead of using the iOS 10
    // formatter.personNameComponents() function to handle last names like firstname=Henny lastname=Looren de Jong
    // An optional suffix like (lid), (aspirantlid) or (mentor) is also removed.
    // This is done in 2 stages using regular expressions because I couldn't get it to work in a single stage.
    // Further more Dutch (and maybe more languages someday) infix prepositions like "van den" are supported.

    private func componentizePersonName(fullName: String, printName: Bool = false) -> PersonName {
        // "José Daniëls" -> ("José","","Daniëls") - former member
        // "Bart van Stekelenburg (lid)" -> ("Bart","van","Steklenburg") - member
        // "Zoë Aspirant (aspirantlid)" -> ("Zoë","","Aspirant") - aspiring member
        // "Hans Zoete (mentor)" -> ("Hans","","Zoete") - coach
        let regex = Regex {
            Capture {
                OneOrMore(.any, .reluctant) // reluctant prevents capturing the " "
            } transform: { givenName in String(givenName) }
            " "
            Capture {
                OneOrMore(
                    ChoiceOf {
                        "van " // NL
                        "de " // NL
                        "den " // NL
                        "der " // NL
                    }
                )
            } transform: { infixName in String(infixName) } // reluctant prevents capturing the optional ChoiceOf
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

        if let match = try? regex.wholeMatch(in: fullName) {
            let (_, givenName, infixNameSpace, familyName) = match.output
            let infixName: String
            if infixNameSpace.last == " " {
                infixName = String(infixNameSpace.dropLast())
            } else {
                infixName = infixNameSpace
            }

            if printName {
                let infixNameWithOptionalSpace = infixName.isEmpty ? infixName : "\(infixName) "
                print("Name found: \(givenName) \(infixNameWithOptionalSpace)\(familyName)")
            }
            return PersonName(fullName: fullName,
                              givenName: givenName, infixName: infixName, familyName: familyName)
        } else {
            print("Error: problem in componentizePersonName() <\(fullName)>")
            return PersonName(fullName: "errorInFullName",
                              givenName: "errorInGivenName",
                              infixName: "errorInInfixName",
                              familyName: "errorInFamilyName")
        }
    }

}
