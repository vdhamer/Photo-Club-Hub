//
//  SearchScope.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/07/2026.
//

import SwiftUI

/// The entity type that the unified Search tab currently filters on.
/// Doubles as the model behind the search field's scope bar (People / Clubs / Maps).
enum SearchScope: CaseIterable, Identifiable, Hashable {
    case people, clubs, maps

    var id: Self { self }

    /// Reuses the existing tab-bar label keys so the scope bar and the tabs stay in sync.
    var label: String {
        switch self {
        case .people:
            String(localized: "People",
                   table: "PhotoClubHub.SwiftUI",
                   comment: "Tab bar label for the list of people (photographers)")
        case .clubs:
            String(localized: "Clubs",
                   table: "PhotoClubHub.SwiftUI",
                   comment: "Tab bar label for the club member portfolios list")
        case .maps:
            String(localized: "Maps",
                   table: "PhotoClubHub.SwiftUI",
                   comment: "Tab bar label for the maps showing organizations")
        }
    }
}
