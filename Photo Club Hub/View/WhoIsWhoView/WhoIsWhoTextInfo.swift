//
//  WhoIsWhoTextInfo.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/04/2024.
//

import SwiftUI

struct WhoIsWhoTextInfo: View {
    var photographer: Photographer
    private let dateFormatter: DateFormatter

    @State private var showPhoneMail = false

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

            // birthday if available (year of birth is not shown)
            if let date: Date = photographer.bornDT {
                let locBirthday = String(localized: "Birthday:",
                                         comment: """
                                                          Birthday of member (without year). \
                                                          Date not currently localized?
                                                          """)
                Text(verbatim: "\(locBirthday) \(dateFormatter.string(from: date))")
                    .font(.subheadline)
                    .foregroundColor(photographer.isDeceased ? .deceasedColor : .primary)
            }

            // phone number if available (and allowed)
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

            // personal (not club-related) web site if available
            if let url: URL = photographer.website {
                Link(destination: url, label: {
                    Text(url.absoluteString)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .font(.subheadline)
                        .foregroundColor(.linkColor)
                })
                .buttonStyle(.plain) // prevents entire List element from becoming clickable
            }
        } .background(.yellow)
    }
}

// #Preview {
//    let photographer = Photographer.findCreateUpdate(context: <#T##NSManagedObjectContext#>,
//                                                     personName: <#T##PersonName#>, organization: <#T##Organization#>)
//
//    WhoIsWhoTexts(photographer: photographer)
// }
