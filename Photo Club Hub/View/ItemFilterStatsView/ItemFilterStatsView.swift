//
//  ItemFilterStatsView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/03/2024.
//

import SwiftUI

/// A small right-aligned stats header showing a count with proper pluralization
/// and an optional "(of X)" suffix when the list is being filtered. See the Preview.
///
/// Examples (English):
/// - "123 organizations"
/// - "12 organizations (of 123)"
/// - "1 photographer (of 123)"
struct ItemFilterStatsView: View { // display right-aligned string like "12 entries (of 123)" or "123 entries"

    // MARK: - Init

    private let filteredCount: Int
    private let unfilteredCount: Int
    private let unit: ElementTypeEnum

    init(filteredCount: Int, unfilteredCount: Int, unit: ElementTypeEnum) {
        self.filteredCount = filteredCount      // Number of items after filtering.
        self.unfilteredCount = unfilteredCount  // Total number of items before filtering.
        self.unit = unit                        // Items that we're counting (key for localization via a String Table)
    }

    // MARK: - SwiftUI body

    var body: some View {
        // Right-align the stats text
        HStack {
            Spacer() // align to trailing edge

            if unfiltered {
                Text(verbatim: "\(localizedFilteredCount(unit: unit))")
            } else {
                let unfilteredCountString = String(localized: "(of \(unfilteredCount))",
                                                   table: "PhotoClubHub.SwiftUI",
                                                   comment: "Suffix showing effect of filtering via \"(of 123)\"")
                Text(verbatim: "\(localizedFilteredCount(unit: unit)) \(unfilteredCountString)")
            }

        }
        .foregroundStyle(.secondary)
        .padding(.trailing)
        .font(.callout) // small font
    }

    // MARK: - Utilities

    private var filtered: Bool { filteredCount != unfilteredCount } // filter active
    private var unfiltered: Bool { !filtered } // no filter active
    private var comment: StaticString {
        // somehow use of variable Comment of type StaticString gives warnings in the build log, but the results do work
        switch unit {
        case .photographer:
            return "Stats header displayed at top of Photographers screen"
        default:
            return "Stats header displayed at top of Organizations screen"
        }
    }

    /// Returns a localized, properly pluralized count string for the given element type.
    /// For `.organization`, the effective unit may be remapped to `.club` or `.museum`
    /// based on user preferences (e.g., when museums are filtered out).
    ///
    /// Examples (English):
    /// - "123 organizations"
    /// - "12 organizations"
    /// - "1 photographer"
    ///
    /// - Parameter unit: The element type to describe (e.g., `.organization`, `.photographer`).
    /// - Returns: A localized string such as "12 organizations" or "1 photographer".
    private func localizedFilteredCount(unit: ElementTypeEnum) -> String {
        switch unit {

        case .photographer:
            return String(localized: "\(filteredCount) photographer",
                          table: "PhotoClubHub.SwiftUI",
                          comment: comment)

        case .club:
            return String(localized: "\(filteredCount) club",
                          table: "PhotoClubHub.SwiftUI",
                          comment: comment)

        case .museum:
            return String(localized: "\(filteredCount) museum",
                          table: "PhotoClubHub.SwiftUI",
                          comment: comment)

        case .member: // still unused?
            return String(localized: "\(filteredCount) member",
                          table: "PhotoClubHub.SwiftUI",
                          comment: comment)

        case .organization: // may change unit to ElementTypeEnum.club if Museums are filted out in Preferences
            let preferences = PreferencesViewModel().preferences
            if preferences.anyClubs && !preferences.showMuseums {
                return localizedFilteredCount(unit: .club)
            } else if !preferences.anyClubs && preferences.showMuseums {
                return localizedFilteredCount(unit: .museum)
            } else {
                return String(localized: "\(filteredCount) organization",
                              table: "PhotoClubHub.SwiftUI",
                              comment: comment)
            }

        }
    }
}

#Preview {
    List {
        ItemFilterStatsView(filteredCount: 100, unfilteredCount: 100, unit: .organization)
        ItemFilterStatsView(filteredCount: 1, unfilteredCount: 1, unit: .organization)
        ItemFilterStatsView(filteredCount: 12, unfilteredCount: 100, unit: .organization)
        ItemFilterStatsView(filteredCount: 1, unfilteredCount: 100, unit: .organization)
        ItemFilterStatsView(filteredCount: 100, unfilteredCount: 100, unit: .photographer)
        ItemFilterStatsView(filteredCount: 1, unfilteredCount: 1, unit: .photographer)
        ItemFilterStatsView(filteredCount: 12, unfilteredCount: 100, unit: .photographer)
        ItemFilterStatsView(filteredCount: 1, unfilteredCount: 100, unit: .photographer)
    }
}
