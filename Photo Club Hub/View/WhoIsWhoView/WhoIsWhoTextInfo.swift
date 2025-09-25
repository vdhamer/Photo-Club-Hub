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

    @State private var animationTrigger: Bool = false

    var body: some View {
        VStack(alignment: .leading) { // lines of text with different pieces of information
            // first green line with icon and name of photographer
            let alive: String = photographer.isDeceased ? // generate name suffix
            (" - " + MemberStatus.deceased.localizedString()) : ""
            Text(verbatim: "\(photographer.fullNameLastFirst)\(alive)")
                .font(.title3)
                .tracking(1)

            if let date: Date = photographer.bornDT {
                if isBirthdaySoon(date, minResult: -1, maxResult: 7) != nil {
                    let locBirthday = String(localized: "Birthday", // birthday if available (year of birth not shown)
                                             table: "PhotoClubHub.SwiftUI",
                                             comment: """
                                                      Birthday of member (without year). \
                                                      Date not currently localized?
                                                      """)
                    Text(verbatim: "\(locBirthday): \(Self.dateFormatter.string(from: date))")
                        .font(.subheadline)
                        .foregroundStyle(photographer.isDeceased ? .deceasedColor : .primary)
                        .phaseAnimator(BirthdayPhaseEnum.allCases, trigger: animationTrigger) { view, phase in
                            view
                                .scaleEffect(phase.scale, anchor: .leading)
                                .offset(x: phase.offsetX, y: phase.offsetY)
                        }
                    animation: {_ in
                        Animation.linear(duration: 0.5)
                    }
                    .onAppear {
                        animationTrigger.toggle() // trigger animation
                    }
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

    enum BirthdayPhaseEnum: CaseIterable {
        case initial // 4 complete cycles
        case expanded
        case initial2
        case expanded2
        case initial3
        case expanded3
        case initial4
        case expanded4
        case initial5

        var offsetX: CGFloat {
            switch self {
            case .initial, .initial2, .initial3, .initial4, .initial5: 0
            case .expanded, .expanded2, .expanded3, .expanded4: -1
            }
        }

        var offsetY: CGFloat {
            switch self {
            case .initial, .initial2, .initial3, .initial4, .initial5: 0
            case .expanded, .expanded2, .expanded3, .expanded4: 3
            }
        }

        var scale: CGFloat {
            switch self {
            case .initial, .initial2, .initial3, .initial4, .initial5: 1
            case .expanded, .expanded2, .expanded3, .expanded4: 1.05
            }
        }
    }

/// Returns the number of days between today and a birthday that falls within a specified window around today.
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
        let timeWindowStart: Date? = calendar.date(byAdding: .day, value: minResult, to: today)
        guard let timeWindowStart: Date else {
            ifDebugFatalError("Calendar.date() returned nil")
            return nil
        }

        let birthdayComponents = calendar.dateComponents([.month, .day], from: birthday)

        let nearbyBirthday: Date = calendar.nextDate(after: timeWindowStart,
                                                     matching: DateComponents(month: birthdayComponents.month,
                                                                              day: birthdayComponents.day),
                                                     matchingPolicy: .nextTime,
                                                     direction: .forward)!

        let interval = TimeInterval((maxResult - minResult) * 24 * 60 * 60) // unit is seconds
        if DateInterval(start: timeWindowStart, duration: interval).contains(nearbyBirthday) {
            let timeDifference: Int? = calendar.dateComponents([.day], from: today, to: nearbyBirthday).day
            return timeDifference
        } else {
            return nil
        }
    }

}
