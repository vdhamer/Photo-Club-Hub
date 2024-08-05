//
//  FGWMembersProvider+extractExternalURL.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/12/2022.
//

import Foundation
import RegexBuilder

extension FotogroepWaalreMembersProvider {

    func extractPhotographerWebsite(taggedString: String) -> String {
        // <td><a title="Ariejan van Twisk fotografie" href="https://www.domain.com" target="_blank">extern</a></td>
        // <td><a title="" href="" target="_blank"></a></td> // old Wordpress template: no URL available
        // <td><a title="" <="" a=""></a></td> // sometimes Wordpress does this if no URL available (bug in WP?)

        let regexURL = Regex {
            " href=\""
            Capture {
                // capturing .url() doesn't work because of trailing quote
                OneOrMore(.any, .reluctant)
            } transform: { urlString in
                URL(string: String(urlString))
            }
            ChoiceOf {
                "\""
                "/\""
            }
        }

        let regexEmpty = Regex {
            " href=\"\""
        }

        if let match = try? regexURL.firstMatch(in: taggedString) { // is a bit more robust than .wholeMatch
            let (_, url) = match.output
            return url?.absoluteString ?? "Error: cannot decode URL"
        } else {
            if (try? regexEmpty.firstMatch(in: taggedString)) != nil {
                return ""
            } else {
                let error = "Bad URL: \(taggedString)"
                print(error)
                return error
            }
        }
    }

}
