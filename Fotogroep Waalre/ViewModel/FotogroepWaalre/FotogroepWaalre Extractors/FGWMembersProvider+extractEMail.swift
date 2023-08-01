//
//  FGWMembersProvider+extractEMail.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/12/2022.
//

import RegexBuilder

extension FotogroepWaalreMembersProvider {

    func extractEMail(taggedString: String) -> String {
        let regex: Regex = Regex {
            "<td><a href=\"mailto:" // <td><a href="mailto:somebody@gmail.com">somebody@gmail.com</a></td>
            Capture {
                OneOrMore(
                    CharacterClass(.anyOf("@").inverted) // somebody
                ) // stop before closing <@>
                "@"                                      // @
                OneOrMore(
                    CharacterClass(.anyOf(".").inverted) // gmail
                ) // stop before closing <.>
                "."                                      // .
                OneOrMore(
                    CharacterClass(.anyOf("\"").inverted) // com
                ) // stop before closing <">
            }
            "\">"
            Capture { // Capture(as:) doesn't really work here because .1 and .2 have same type
                OneOrMore(
                    CharacterClass(.anyOf("@").inverted) // somebody
                ) // stop before closing <@>
                "@"                                      // @
                OneOrMore(
                    CharacterClass(.anyOf(".").inverted) // gmail
                ) // stop before closing <.>
                "."                                      // .
                OneOrMore(
                    CharacterClass(.anyOf("<").inverted) // com
                )
            }
            "</a></td>"
        }

        if let match = try? regex.firstMatch(in: taggedString) { // is a bit more robust than .wholeMatch
            let (_, email1, email2) = match.output
            if email1 != email2 {
                print("""
                      Warning: mismatched e-mail addresses\
                                  \(email1)\
                                  \(email2)
                      """)
            }
            return String(email1)
        } else {
            let error = "Bad e-mail: \(taggedString)"
            print(error)
            return error
        }
    }

}
