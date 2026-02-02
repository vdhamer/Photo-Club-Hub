//
//  ItemFilterStatsView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/03/2024.
//

import SwiftUI

/// A small right-aligned stats header showing a count with proper pluralization
/// and an optional "(of X)" suffix when a filter is active. See the preview.
///
/// Examples:
/// - "123 organizations"
/// - "12 organizations (of 123)"
/// - "1 photographer (of 123)"
struct ItemFilterStatsView: View { // display right-aligned string like "12 entries (of 123)" or "123 entries"

    init(filteredCount: Int, unfilteredCount: Int, unit: ElementTypeEnum) {
        self.filteredCount = filteredCount
        self.unfilteredCount = unfilteredCount
        self.unit = unit
    }

    /// Number of items after filtering.
    private let filteredCount: Int
    /// Total number of items before filtering.
    private let unfilteredCount: Int
    /// What we are counting (key for localization via String Table)
    private let unit: ElementTypeEnum

    var body: some View {
        // Right-align the stats text
        HStack {
            Spacer() // allign to trailing edge

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

        var filtered: Bool { filteredCount != unfilteredCount } // filter active
        var unfiltered: Bool { !filtered } // no filter active
    }

    private var comment: StaticString {
        // somehow use of variable Comment of type StaticString gives warnings in the build log, but the results do work
        switch unit {
        case .photographer:
            return "Stats header displayed at top of Who's who screen"
        default:
            return "Stats header displayed at top of Organizations screen"
        }
    }

    private func localizedFilteredCount(unit: ElementTypeEnum) -> String {
        switch unit {
        case .photographer:
            return String(localized: "\(filteredCount) photographer",
                          table: "PhotoClubHub.SwiftUI",
                          comment: comment)
        case .organization:
            if PreferencesViewModel().preferences.anyClubs && !PreferencesViewModel().preferences.showMuseums {
                return localizedFilteredCount(unit: .club)
            } else if !PreferencesViewModel().preferences.anyClubs && PreferencesViewModel().preferences.showMuseums {
                return localizedFilteredCount(unit: .museum)
            }
            return String(localized: "\(filteredCount) organization",
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
