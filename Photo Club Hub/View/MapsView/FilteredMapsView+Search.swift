//
//  FilteredMapsView+Search.swift
//  Photo Club Hub
//
//  Created by Claude Code (guided by Peter van den Hamer) on 07/11/2026.
//

import Photo_Club_Hub_Data // for Organization, Language, String.normalizedTypography

extension FilteredMapsView { // the search field on the Maps tab

    /// True when the search text occurs in the organization's name, its stored town, or its town in the
    /// interface language: the town its card shows (Data#88).
    ///
    /// So "Keulen" in Dutch, "Cologne" in English and "Köln" in either setting find Museum Ludwig.
    ///
    /// The localized town is Apple's name for the place at the coordinates.
    /// Names and towns are stored with plain hyphens, apostrophes and quotes (Data#100). Benefit: the search text is
    /// normalized the same way: a curly apostrophe typed by the iOS keyboard still finds "'s-Hertogenbosch".
    /// The "Town?" placeholder is matched like any town, because the card shows it:
    /// searching "Town?" lists the organizations for which Apple gave no town, a check for maintainers.
    ///
    /// Static, without the view's state, so that it can be tested.
    /// - Parameter language: the interface language, or nil when the `Language` table has not been seeded yet,
    ///   in which case only the name and the stored town are compared.
    static func matches(_ organization: Organization, searchText: String, language: Language?) -> Bool {
        let searchText = searchText.normalizedTypography
        if organization.fullNameTown.localizedCaseInsensitiveContains(searchText) {
            return true
        }

        guard let language else { return false } // Language table not seeded yet

        return organization.localizedTown(for: language).localizedCaseInsensitiveContains(searchText)
    }

}
