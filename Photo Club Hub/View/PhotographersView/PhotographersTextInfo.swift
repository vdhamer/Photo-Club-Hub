//
//  PhotographersTextInfo.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/04/2024.
//

import SwiftUI // for View
import WebKit // for WKWebView
import MapKit // for CLLocationCoordinate2D

// Implements a few lines of text at top of each photographer card, containing:
//     * an icon (with a special icon if the photographer is deceased)
//     * photographer's name (last name first)
//     * optionally a link icon that leads to the phototographer's own website
//     * some textual information
//     * a horizontally scrolling list of thumbnails representing portfolios
// Preview is commented out (doesn't work yet).

struct PhotographersTextInfo: View {
    var photographer: Photographer
    let wkWebView: WKWebView

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM"
        return formatter
    }()

    init(photographer: Photographer, wkWebView: WKWebView) {
        self.photographer = photographer
        self.wkWebView = wkWebView
    }

    @State private var animationTrigger: Bool = false

    var body: some View {
        VStack(alignment: .leading) { // lines of text with different pieces of information
            // first green line with icon and name of photographer
            let alive: String = photographer.isDeceased ? // generate name suffix
                (" - " + MemberStatus.deceased.displayName) : ""
            let websiteLabelText = Text(verbatim: "\(photographer.fullNameLastFirst)\(alive)")
                .font(.title3)
                .tracking(1)
            // links to personal (not club-related) web site if available
            if let url: URL = photographer.photographerWebsite {
                Link(destination: url, label: {
                    websiteLabelText
                })
                .buttonStyle(.plain)
            } else {
                websiteLabelText
            }

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

// MARK: - Previews

// Believe it or not, these 3 previews actually works.
#Preview("Photographer with Birthday soon") {
    let controller = PersistenceController(inMemory: true)
    let context = controller.container.viewContext

    // Create a photographer with a birthday coming up
    let calendar = Calendar.current
    let today = Date()
    // Set birthday to 3 days from now
    let birthdayComponents = calendar.dateComponents([.month, .day],
                                                     from: calendar.date(byAdding: .day, value: 3, to: today)!)
    var dateComponents = DateComponents()
    dateComponents.month = birthdayComponents.month
    dateComponents.day = birthdayComponents.day
    dateComponents.year = 1975 // Some year in the past
    let birthdayDate = calendar.date(from: dateComponents)!

    let photographer = Photographer.findCreateUpdate(
        context: context,
        personName: PersonName(givenName: "Jane", infixName: "van", familyName: "Doe"),
        optionalFields: PhotographerOptionalFields(
            bornDT: birthdayDate,
            isDeceased: false,
            photographerWebsite: URL(string: "https://www.janedoe-photography.com")
        )
    )

    // create new organization to house `photographer`
    let organization = Organization.findCreateUpdate(
        context: context, // on main thread
        organizationTypeEnum: .club,
        idPlus: OrganizationIdPlus(
            fullName: "PhotoClub",
            town: "Town",
            nickname: "ClubNick"
        ),
        coordinates: CLLocationCoordinate2D( // spread around BeNeLux
            latitude: 51.39184 + Double.random(in: -2.0 ... 2.0),
            longitude: 5.46144 + Double.random(in: -2.0 ... 1.0)),
        optionalFields: OrganizationOptionalFields(
            organizationWebsite: URL(string: "http://www.example.com)"),
            fotobondClubNumber: FotobondClubNumber(id: Int16(1234))
        ),
        pinned: false
    )

    try? context.save()

    // make photographer member of club
    _ = MemberPortfolio.findCreateUpdate(
        bgContext: context,
        organization: organization,
        photographer: photographer,
        optionalFields: MemberOptionalFields(
            featuredImage: URL(string: "https://picsum.photos/512"), // image is dynamically generated
            featuredImageThumbnail: URL(string: "https://picsum.photos/300"), // image is dynamically generated
            memberRolesAndStatus: MemberRolesAndStatus( roles: [.chairman: true,
                                                                .treasurer: true],
                                                        status: [.former: true] )
        )
    )

    return VStack(alignment: .leading) {
        VStack {
            PhotographersTextInfo(photographer: photographer, wkWebView: WKWebView())
                .border(Color.gray.opacity(0.3), width: 1)
            Divider()
            Text(verbatim: "Preview: Photographer with birthday in 3 days")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("Deceased Photographer") {
    let controller = PersistenceController(inMemory: true)
    let context = controller.container.viewContext

    // Create a photographer
    let photographer = Photographer.findCreateUpdate(
        context: context,
        personName: PersonName(givenName: "John", infixName: "", familyName: "Smith"),
        optionalFields: PhotographerOptionalFields(
            bornDT: Date(timeIntervalSince1970: 315532800), // January 1, 1980
            isDeceased: true,
            photographerWebsite: URL(string: "https://www.johnsmith-memorial.org")
        )
    )

    try? context.save()

    return VStack(alignment: .leading) {
        VStack {
            PhotographersTextInfo(photographer: photographer, wkWebView: WKWebView())
                .border(Color.gray.opacity(0.3), width: 1)
            Divider()
            Text(verbatim: "Preview: Deceased photographer")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview("Photographer Without Website") {
    let controller = PersistenceController(inMemory: true)
    let context = controller.container.viewContext

    let photographer = Photographer.findCreateUpdate(
        context: context,
        personName: PersonName(givenName: "Alice", infixName: "de", familyName: "Berg"),
        optionalFields: PhotographerOptionalFields(
            bornDT: nil,
            isDeceased: false,
            photographerWebsite: nil
        )
    )

    try? context.save()

    return VStack(alignment: .leading) {
        VStack {
            PhotographersTextInfo(photographer: photographer, wkWebView: WKWebView())
                .border(Color.gray.opacity(0.3), width: 1)
            Divider()
            Text(verbatim: "Preview: No birthday or website")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
