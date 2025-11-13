//
//  PersonName.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 23/09/2023.
//

import RegexBuilder

public struct PersonName {
    var fullNameWithParenthesizedRole: String // "John Doe (lid)" or "Jan van Doesburg"
    let givenName: String // "John" or "Jan"
    let infixName: String // "" or "van"
    let familyName: String // "Doe" or "Doesburg"

    public init(fullNameWithParenthesizedRole: String? = nil,
                givenName: String,
                infixName: String,
                familyName: String) {
        // if fullNameWithParenthesizedRole not provide, synthesize it without a  role
        self.fullNameWithParenthesizedRole = fullNameWithParenthesizedRole != nil ? fullNameWithParenthesizedRole! :
                                             givenName + " " +
                                             (infixName.isEmpty ? "" : "\(infixName) ") +
                                             familyName
        self.givenName = givenName
        self.infixName = infixName
        self.familyName = familyName
    }

    var fullNameWithoutParenthesizedRole: String {
        return removeParenthesizedRole(fullNameWithParenthesizedRole: fullNameWithParenthesizedRole)
    }

    @available(macOS 13.0, *)
    private func removeParenthesizedRole(fullNameWithParenthesizedRole: String) -> String {
        // "José Daniëls" -> "José Daniëls" - former member
        // "Bart van Stekelenburg (lid)" -> "Bart van Stekelenburg" - member
        // "Zoë Aspirant (aspirantlid)" -> "Zoë Aspirant" - aspiring member
        // "Hans Zoete (mentor)" -> "Hans Zoete" - coach
        let regex = Regex {
            Capture {
                OneOrMore(.any, .reluctant)
            } transform: { fullName in String(fullName) }
            Optionally {
                " (" // e.g. " (lid)"
                OneOrMore(.any)
            }
        }

        if let match = try? regex.wholeMatch(in: fullNameWithParenthesizedRole) {
            let (_, fullName) = match.output
            return fullName
        } else {
            ifDebugFatalError("Error: problem performing removeParenthesizedRole(\(fullNameWithParenthesizedRole))")
            return fullNameWithParenthesizedRole
        }
    }
}
