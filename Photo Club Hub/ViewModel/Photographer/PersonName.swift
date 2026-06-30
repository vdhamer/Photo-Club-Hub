//
//  PersonName.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 23/09/2023.
//

import RegexBuilder // for Regex { }

/// A person's name, split into its constituent parts and optionally carrying a club role.
///
/// Dutch names often contain an infix (a "tussenvoegsel" such as "van" or "de") that sits
/// between the given name and the family name, so it is stored separately rather than being
/// folded into the family name. The display string may also include a parenthesized role
/// (e.g. "(lid)") that callers can strip when only the bare name is needed.
public struct PersonName {
    /// The display name, including any parenthesized role, e.g. "John Doe (lid)" or "Jan van Doesburg".
    var fullNameWithParenthesizedRole: String
    /// The given (first) name, e.g. "John" or "Jan".
    let givenName: String
    /// The infix ("tussenvoegsel"), e.g. "" or "van" or "op de". Uses an empty String when the name has no infix.
    let infixName: String
    /// The family (last) name, e.g. "Doe" or "Doesburg".
    let familyName: String
    /// The display name with any trailing parenthesized role removed, e.g.
    /// "Bart van Stekelenburg (lid)" becomes "Bart van Stekelenburg".
    var fullNameWithoutParenthesizedRole: String {
        return removeParenthesizedRole(fullNameWithParenthesizedRole: fullNameWithParenthesizedRole)
    }

    /// Creates a PersonName from its parts.
    ///
    /// - Parameters:
    ///   - fullNameWithParenthesizedRole: The display name including any role. When `nil`, it is
    ///     synthesized from the other parameters as "given [infix ]family" with no role.
    ///   - givenName: The given (first) name.
    ///   - infixName: The infix ("tussenvoegsel"); pass an empty string when there is none.
    ///   - familyName: The family (last) name.
    public init(fullNameWithParenthesizedRole: String? = nil,
                givenName: String,
                infixName: String,
                familyName: String) {
        // if fullNameWithParenthesizedRole not provide, synthesize it without a  role
        self.fullNameWithParenthesizedRole = fullNameWithParenthesizedRole != nil ? fullNameWithParenthesizedRole! :
                                             givenName + " " + (infixName.isEmpty ? "" : "\(infixName) ") + familyName
        self.givenName = givenName
        self.infixName = infixName
        self.familyName = familyName
    }

    /// Strips a trailing " (role)" suffix from a full name, leaving the name itself untouched.
    /// Returns the input unchanged if it contains no parenthesized role.
    @available(macOS 13.0, *)
    private func removeParenthesizedRole(fullNameWithParenthesizedRole: String) -> String {
        // "José Daniëls" → "José Daniëls" - former member
        // "Bart van Stekelenburg (lid)" → "Bart van Stekelenburg" - member
        // "Zoë Aspirant (aspirantlid)" → "Zoë Aspirant" - aspiring member
        // "Hans Zoete (mentor)" → "Hans Zoete" - coach
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
