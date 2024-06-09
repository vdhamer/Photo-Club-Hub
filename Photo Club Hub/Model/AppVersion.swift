//
//  AppVersion.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/06/2024.
//

import Foundation
import RegexBuilder

// support for semantic versioning
struct AppVersion: Comparable {

    let major: Int
    let minor: Int
    let patch: Int

    // initializer fills (major, minor, patch). If input versionString is bad, result is (0, 0, 0)
    init(_ versionString: String) {
        let regex = Regex {
            Capture {
                OneOrMore(.digit)
            }
            transform: { major in Int(major) }
            "."
            Capture {
                OneOrMore(.digit)
            }
            transform: { minor in Int(minor) }
            "."
            Capture {
                OneOrMore(.digit)
            }
            transform: { patch in Int(patch) }
            ZeroOrMore {
                ChoiceOf {
                    .whitespace
                    .regex.asciiOnlyWordCharacters()
                }
            }
        }

        if let match: Regex.Match = try? regex.prefixMatch(in: versionString) {
            let (_, major, minor, patch) = match.output
            self.major = major ?? 0
            self.minor = minor ?? 0
            self.patch = patch ?? 0
        } else {
            self.major = 0
            self.minor = 0
            self.patch = 0
        }

    }

    // without a parameter, fetch app's version string
    init() {
        self.init(Bundle.main.shortVersion)
    }

    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        } else if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        } else {
            return lhs.patch < rhs.patch
        }
    }

}
