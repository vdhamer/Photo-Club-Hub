//
//  FGWMembersProvider+extractPhone.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/12/2022.
//

import RegexBuilder

extension FotogroepWaalreMembersProvider {

    func extractPhone(taggedString: String) -> String? {
        let regex = Regex {
            "<td>"
            Capture {
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

        if let match = try? regex.firstMatch(in: taggedString) { // is a bit more robust than .wholeMatch
            let (_, phone) = match.output
            if phone != "?" {
                return String(phone)
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
