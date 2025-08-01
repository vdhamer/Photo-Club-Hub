//
//  WhoIsWhoTextInfo.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/04/2024.
//

import SwiftUI

// Implements a few lines of text at top of each photographer card, containing:
//     * an icon (with a special icon if the photographer is deceased)
//     * photographer's name (last name first)
//     * optionally a link icon that leads to the phototographer's own website
//     * some textual information
//     * a horizontally scrolling list of thumbnails representing portfolios
// Preview is commented out (doesn't work yet).

struct WhoIsWhoTextInfo: View {
    var photographer: Photographer

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM"
        return formatter
    }()

    init(photographer: Photographer) {
        self.photographer = photographer
    }

    var body: some View {
        VStack(alignment: .leading) { // lines of text with different pieces of information
            // first green line with icon and name of photographer
            let alive: String = photographer.isDeceased ? // generate name suffix
                (" - " + MemberStatus.deceased.localizedString()) : ""
                Text(verbatim: "\(photographer.fullNameLastFirst)\(alive)")
                    .font(.title3)
                    .tracking(1)

            let locBirthday = String(localized: "Birthday", // birthday if available (year of birth is not shown)
                                     comment: """
                                              Birthday of member (without year). \
                                              Date not currently localized?
                                              """)
            if let date: Date = photographer.bornDT {
                if isBirthdaySoon(date, minResult: -1, maxResult: 7) != nil {
                    Text(verbatim: "\(locBirthday): \(Self.dateFormatter.string(from: date))")
                        .font(.subheadline)
                        .foregroundStyle(photographer.isDeceased ? .deceasedColor : .primary)
                }
            }

            // personal (not club-related) web site if available
            if let url: URL = photographer.photographerWebsite {
                Link(destination: url, label: {
                    Text(url.absoluteString)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .font(.subheadline)
                        .foregroundColor(.linkColor)
                })
                // prevents entire List element from becoming clickable
                .buttonStyle(.plain)
            }
        }
    }
}

/// Returns the number of days until the next occurrence of a birthday that falls within a specified window around today.
///
/// - Parameters:
///   - birthday: The birth date (only month and day are considered).
///   - minResult: The negative number of days before today to start the search window (e.g., -1 for yesterday).
///   - maxResult: The positive number of days after today to end the search window (e.g., 7 for one week ahead).
/// - Returns: The number of days until the next birthday if it's within the window (0 means today), otherwise `nil`.
/// - Note: Returns `nil` if the window does not include a nearby birthday, or if improper parameters are given.
/// - Note: Returns a small negative number of birthday occurred a few days ago.
func isBirthdaySoon(_ birthday: Date, minResult: Int = -1, maxResult: Int = 7) -> Int? {
    guard minResult <= 0 && maxResult >= 0 else {
        ifDebugFatalError("minResults should <= 0 and maxResults should be >= 0")
        return nil
    }

    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let timeWindowStart: Date? = calendar.date(byAdding: .day, value: -1 * minResult, to: today)
    guard let timeWindowStart: Date else {
        ifDebugFatalError("Calendar.date() returned nil")
        return nil
    }

    let birthdayComponents = calendar.dateComponents([.month, .day], from: birthday)

    let compTimeWindowStart: DateComponents = calendar.dateComponents([.month, .day], from: timeWindowStart)
    if birthdayComponents == compTimeWindowStart {
        return 0
    }
    let nearbyBirthday: Date = calendar.nextDate(after: timeWindowStart,
                                                 matching: DateComponents(timeZone: birthdayComponents.timeZone,
                                                                          month: birthdayComponents.month,
                                                                          day: birthdayComponents.day),
                                                 matchingPolicy: .nextTime,
                                                 direction: .forward)!

    let interval = TimeInterval((minResult + maxResult) * 24 * 60 * 60) // unit is seconds
    if !DateInterval(start: timeWindowStart, duration: interval).contains(nearbyBirthday) {
        return nil
    } else {
        return calendar.dateComponents([.day], from: today, to: nearbyBirthday).day
    }
}

