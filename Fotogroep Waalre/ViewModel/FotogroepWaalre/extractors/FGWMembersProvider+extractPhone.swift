//
//  FGWMembersProvider+extractPhone.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 26/12/2022.
//

import RegexBuilder

extension FGWMembersProvider {

    func extractPhone(taggedString: String) -> String? {
        let phoneCapture = Reference(Substring.self)
        let regex = Regex {
            "<td>"
            Capture(as: phoneCapture) {
                ChoiceOf {
                    One("[overleden]") // accepts <td>[overleden]</td> in NL
                    One("[deceased]") // accepts <td>[deceased]</td> in EN
                    OneOrMore { // accepts <td>12345678</td> or <td>06-12345678</td> or <td>+31 6 12345678</td>
                        CharacterClass(
                            .anyOf("-+ "),
                            ("0"..."9")
                        )
                    }
                    One("?") // signifies that phone number is unknown
                }
            }
            "</td>"
        }

        if let result = try? regex.firstMatch(in: taggedString) { // is a bit more robust than .wholeMatch
            if result[phoneCapture] != "?" {
                return String(result[phoneCapture])
            } else {
                return nil
            }
        } else {
            let error = "Bad tel#: \(taggedString)"
            print(error)
            return error
        }
    }

}
