//
//  FGWMembersProvider+extractEMail.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 26/12/2022.
//

import RegexBuilder

extension FGWMembersProvider {

    func extractEMail(taggedString: String) -> String {
        let emailCapture = Reference(Substring.self)
        let regex: Regex = Regex {
            "<td><a href=\"mailto:" // <td><a href="mailto:somebody@gmail.com">somebody@gmail.com</a></td>
            Capture(as: emailCapture) {
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

        if let result = try? regex.firstMatch(in: taggedString) { // is a bit more robust than .wholeMatch
            if result[emailCapture] != result.2 {
                print("""
                      Warning: mismatched e-mail addresses\
                                  \(result[emailCapture])\
                                  \(result.2)
                      """)
            }
            return String(result[emailCapture])
        } else {
            let error = "Bad e-mail: \(taggedString)"
            print(error)
            return error
        }
    }

}
