//
//  FGWMerbersProvider+extractName.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 25/12/2022.
//

import RegexBuilder

extension FotogroepWaalreMembersProvider {

    func extractName(taggedString: String) -> PersonName {
        let fullName = removeTags(taggedString: taggedString)
        return componentizePersonName(fullNameWithParenthesizedRole: fullName, printName: false)
    }

    // Returns fullName String by stripping off certain HTML tags

    private func removeTags(taggedString: String) -> String {
        // "<td>José Daniëls</td>" -> "José Daniëls"
        // "<td>Bart van Stekelenburg (lid)</td>" -> "Bart van Stekelenburg (lid)"
        // "<td>Zoë Aspirant (aspirantlid)</td>" -> "Zoë Aspirant (aspirantlid)"
        // "<td>Hans Zoete (mentor)</td>" -> "Hans Zoete (mentor)"
        let regex = Regex {
            "<td>"
            Capture {
                OneOrMore(.any, .reluctant)
            }
            "</td>"
        }

        if let match = try? regex.firstMatch(in: taggedString) { // is a bit more robust than .wholeMatch
            let (_, nameSubstring) = match.output
            let name = String(nameSubstring) // debugger has problems showing value of nameSubString type
            return name
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
    // Furthermore Dutch (and maybe more languages someday) infix prepositions like "van den" are supported.

    // swiftlint:disable function_body_length
    private func componentizePersonName(fullNameWithParenthesizedRole: String, printName: Bool = false) -> PersonName {
        // "José Daniëls" -> ("José","","Daniëls") - former member
        // "Bart van Stekelenburg (lid)" -> ("Bart","van","Steklenburg") - member
        // "Zoë Aspirant (aspirantlid)" -> ("Zoë","","Aspirant") - aspiring member
        // "Hans Zoete (mentor)" -> ("Hans","","Zoete") - coach
        let regex = Regex {
            Capture {
                OneOrMore(.word, .eager) // not sure about given names like "Eric-Jan", but need to stop on a space
            } transform: { givenName in String(givenName) }
            Optionally {
                " "
            }
            Capture {
                OneOrMore(
                    ChoiceOf { // https://www.van-diemen-de-jel.nl/Genea/Spelling.html
                        "van" // NL
                        "den" // NL
                        "der" // NL
                        "de" // NL
                        "het" // NL
                        "ter" // NL
                        "ten" // NL
                        "te" // NL
                        "D'"// FR
                        "von" // DE
                        " " // doesn't count as infix, but needed with or without infix
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

        if let match = try? regex.wholeMatch(in: fullNameWithParenthesizedRole) {
            let (_, givenName, infixNameSpace, familyName) = match.output

            let infixName = (infixNameSpace.last == " ") ? String(infixNameSpace.dropLast()) : infixNameSpace
            if printName { print("Name found: \(fullNameWithParenthesizedRole)") }
            return PersonName(fullNameWithParenthesizedRole: fullNameWithParenthesizedRole,
                              givenName: givenName, infixName: infixName, familyName: familyName)
        } else {
            ifDebugFatalError("Error: problem in componentizePersonName(\(fullNameWithParenthesizedRole))")
            return PersonName(fullNameWithParenthesizedRole: "errorInFullName",
                              givenName: "errorInGivenName",
                              infixName: "errorInInfixName",
                              familyName: "errorInFamilyName")
        }
    }
    // swiftlint:enable function_body_length

}
