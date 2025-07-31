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
    fileprivate let dateFormatter: DateFormatter

    init(photographer: Photographer) {
        self.photographer = photographer

        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM" // used here for birthdays only, so year is hidden
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
                    Text(verbatim: "\(locBirthday): \(dateFormatter.string(from: date))")
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
                .buttonStyle(.plain) // prevents entire List element from becoming clickable
            }
        }
    }
}

func isBirthdaySoon(_ birthday: Date, minResult: Int = -1, maxResult: Int = 7) -> Int? {

    let tymdComponents: Set<Calendar.Component> = [.timeZone, .year, .month, .day]
    let today: Date = Calendar.current.date(from: Calendar.current.dateComponents(tymdComponents, from: Date.now))!

    let birthday: Date = Calendar.current.date(from: Calendar.current.dateComponents(tymdComponents, from: birthday))!
    let tmdComponents: Set<Calendar.Component> = [.timeZone, .month, .day]
    let compBirthday = Calendar.current.dateComponents(tmdComponents, from: birthday)
    let timeWindowStart: Date? = Calendar.current.date(byAdding: .day, value: -1 * abs(minResult), to: today)
    guard let timeWindowStart: Date else { return nil } // unwrap
    let compTimeWindowStart: DateComponents = Calendar.current.dateComponents(tmdComponents, from: timeWindowStart)
    if compBirthday == compTimeWindowStart { return 0 }
    let nearbyBirthday: Date = Calendar.current.nextDate(after: timeWindowStart,
                                                         matching: DateComponents(timeZone: compBirthday.timeZone,
                                                                                  month: compBirthday.month,
                                                                                  day: compBirthday.day),
                                                         matchingPolicy: .nextTime,
                                                         direction: .forward)!

    let interval = TimeInterval((abs(minResult) + abs(maxResult)) * 24 * 60 * 60) // unit is seconds
    if !DateInterval(start: timeWindowStart, duration: interval).contains(nearbyBirthday) {
        return nil
    } else {
        return Calendar.current.dateComponents([.day], from: today, to: nearbyBirthday).day
    }
}
