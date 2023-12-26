//
//  OrganizationType.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/12/2023.
//

import Foundation

enum OrganizationType { // enum rawValue feature not used because string needs localization
    case clubs
    case musea

    var unlocalizedString: String {
        switch self {
        case .clubs:
            return "clubs"
        case .musea:
            return "museums"
        }
    }

    func localizedString() -> String { // cannot simply using String(localized: unlocalizedString)
        switch self {
        case .clubs:
            return String(localized: "clubs",
                          comment: "Mode for the Clubs page: show photo clubs as sections.")
        case .musea:
            return String(localized: "musea",
                          comment: "Mode for the Clubs page: show musea as sections.")
        }
    }
}
