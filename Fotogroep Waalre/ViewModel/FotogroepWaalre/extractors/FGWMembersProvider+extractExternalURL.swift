//
//  FGWMembersProvider+extractExternalURL.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 26/12/2022.
//

import RegexBuilder

extension FGWMembersProvider {

    func extractExternalURL_old(taggedString: String) -> String {
        // swiftlint:disable:next line_length
        // <td><a title="Ariejan van Twisk fotografie" href="http://www.ariejanvantwiskfotografie.nl" target="_blank">extern</a></td>
        // <td><a title="" href="" target="_blank"></a></td> // old Wordpress template: no URL available
        // <td><a title="" <="" a=""></a></td> // sometimes Wordpress does this if no URL available (bug in WP?)

        let REGEX: String = " href=\"([^\"]*)\""
        let result = taggedString.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return result[0]
        } else {
            return "" // backup in " href=..." not found
        }
    }

    func extractExternalURL(taggedString: String) -> String {
        // swiftlint:disable:next line_length
        // <td><a title="Ariejan van Twisk fotografie" href="http://www.ariejanvantwiskfotografie.nl" target="_blank">extern</a></td>
        // <td><a title="" href="" target="_blank"></a></td> // old Wordpress template: no URL available
        // <td><a title="" <="" a=""></a></td> // sometimes Wordpress does this if no URL available (bug in WP?)

        let REGEX: String = " href=\"([^\"]*)\""
        let result = taggedString.capturedGroups(withRegex: REGEX)
        if result.count > 0 {
            return result[0]
        } else {
            return "" // backup in " href=..." not found
        }
    }

}
