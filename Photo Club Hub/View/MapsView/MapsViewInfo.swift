//
//  MapsViewInfo.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI // for View
import Photo_Club_Hub_Data // for types like Organization

/// Type-icon on the left, few rows of text on the right, tapable lock symbol. Called from FilteredMapsView.
@MainActor
struct MapsViewInfo: View {

    @Environment(\.layoutDirection) var layoutDirection // .leftToRight or .rightToLeft

    let organizationType: OrganizationTypeEnum
    let localizedTown: String
    let localizedCountry: String
    let memberCount: Int
    let organizationWebsite: URL?
    @Binding var isMapScrollLocked: Bool // owned by the card (`MapsViewCard`), which also passes it to the map

    /// - Parameter language: the language to show the address in, or nil when the `Language` table has
    ///   not been seeded yet. Nil falls back to the unlocalized town the JSON supplied (#827).
    init(organization: Organization, // higher level initializer for production
         language: Language?,
         isMapScrollLocked: Binding<Bool>) {
        organizationType = organization.organizationType.organizationTypeEnum
        if let language {
            localizedTown = organization.localizedTown(for: language)
            localizedCountry = organization.localizedCountry(for: language)
        } else {
            localizedTown = organization.town
            localizedCountry = LocalizedAddress.unknownCountry
        }
        memberCount = organization.members.count
        organizationWebsite = organization.organizationWebsite
        _isMapScrollLocked = isMapScrollLocked
    }

    fileprivate init(organizationType: OrganizationTypeEnum, // lower level initiatizer used by preview
                     localizedTown: String,
                     localizedCountry: String,
                     memberCount: Int,
                     organizationWebsite: URL?,
                     isMapScrollLocked: Binding<Bool>) {
        self.organizationType = organizationType
        self.localizedTown = localizedTown
        self.localizedCountry = localizedCountry
        self.memberCount = memberCount
        self.organizationWebsite = organizationWebsite
        self._isMapScrollLocked = isMapScrollLocked
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // The same balloon as this organization's own (purple) marker on the map below.
            MapMarkerBalloon(organizationType: organizationType,
                             isOwn: true, // so Fotobond and settings don't matter
                             isInFotobond: false,
                             settings: .defaultValue)
                .padding(.leading, 5)
                .padding(.trailing, 12) // the gap to the text

            VStack(alignment: .leading) {

                // location consisting of town and country
                Text(verbatim: layoutDirection == .leftToRight ?
                     "\(localizedTown), \(localizedCountry)" :
                     "\(localizedCountry) ,\(localizedTown)")
                .font(.subheadline)

                // number of members (if applicable)
                if memberCount > 0 { // hide for museums and clubs without members
                    Text("\(memberCount) members (inc. ex-members)",
                         tableName: "PhotoClubHub.SwiftUI",
                         comment: "<count> members (including all types of members) within photo club")
                    .font(.subheadline)
                }

                // URL to existing club/museum website
                if let website: URL = organizationWebsite {
                    Link(destination: website, label: {
                        Text(website.absoluteString)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .font(.subheadline)
                            .foregroundColor(.linkColor)
                    })
                    .buttonStyle(.plain) // to avoid entire List element to be clickable
                }

            }

            // lock icon
            Spacer() // moved Button to trailing/right side
            Button(
                action: {
                    openCloseSound(openClose: isMapScrollLocked ? .close : .open)
                    isMapScrollLocked.toggle()
                },
                label: {
                    HStack { // to make background color clickable too
                        LockAnimationView(locked: isMapScrollLocked)
                    }
                    .frame(width: 60, height: 60)
                    .contentShape(Rectangle())
                }
            )
            .buttonStyle(.plain) // to avoid entire List element to be clickable
        }
        .padding(.all, 0)
        .accentColor(.mapsColor)
    }
}

// MARK: - Previews

// Believe it or not, these previews actually work.

#Preview {
    @Previewable @State var lockedClub1 = false
    @Previewable @State var lockedClub2 = true

    VStack(alignment: .leading, spacing: 20) {
        Divider()
        MapsViewInfo(organizationType: .club,
                             localizedTown: "Eindhoven",
                             localizedCountry: "Netherlands",
                             memberCount: 20,
                             organizationWebsite: URL(string: "https://www.fcDeGender.nl"),
                             isMapScrollLocked: $lockedClub1)
        Divider()
        MapsViewInfo(organizationType: .unknown,
                             localizedTown: "Nieuw Amsterdam",
                             localizedCountry: "Verenigde Staten",
                             memberCount: 0,
                             organizationWebsite: nil,
                             isMapScrollLocked: $lockedClub2)
        Divider()
        HStack {
            Spacer()
            Text(verbatim: "Note that the lock icons are clickable.")
                .italic()
                .font(.caption)
            Spacer()
        }
    }
    .padding()
}
