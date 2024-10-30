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

    @State fileprivate var showPhoneMail = false

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
                Text(verbatim: "\(locBirthday): \(dateFormatter.string(from: date))")
                    .font(.subheadline)
                    .foregroundStyle(photographer.isDeceased ? .deceasedColor : .primary)
            } else {
                Text("Birthday unknown", comment: "If photographer's birthday info is unavailable (Who's Who screen).")
                    .font(.subheadline)
                    .foregroundStyle(photographer.isDeceased ? .deceasedColor : .secondary)
            }

            // phone number if available (and allowed)
            /*
            if photographer.phoneNumber != "", showPhoneMail, photographer.isAlive {
                let locPhone = String(localized: "Phone:",
                                      comment: "Telephone number (usually invisible)")
                Text(verbatim: "\(locPhone): \(photographer.phoneNumber)")
                    .font(.subheadline)
                    .foregroundColor(.primary) // don't show phone numbers for deceased people
            }

            // phone number if available (and allowed)
            if photographer.eMail != "", showPhoneMail, !photographer.isDeceased {
                Text(verbatim: "mailto://\(photographer.eMail)")
                    .font(.subheadline)
                    .foregroundColor(.primary) // don't show e-mail addresses for deceased people
            }
            */

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
            } else {
                Text("No known personal website",
                     comment: "Shown on Who's Who screen If photographer has no personal website.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
