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
    let status: OrganizationStatus // an inactive organization gets a ghost marker and a line saying so (#892)
    let localizedTown: String
    let localizedCountry: String
    let memberCount: Int
    let organizationWebsite: URL?
    @Binding var isMapScrollLocked: Bool // owned by the card (`MapsViewCard`), which also passes it to the map

    /// - Parameter uiLanguage: user interface language in which, to show the address, or nil when the `Language` table
    ///   has not been seeded yet. Nil falls back to the unlocalized town the JSON supplied (#827).
    init(organization: Organization, // higher level initializer for production
         uiLanguage: Language?,
         isMapScrollLocked: Binding<Bool>) {
        organizationType = organization.organizationType.organizationTypeEnum
        status = organization.status
        if let uiLanguage {
            localizedTown = organization.localizedTown(for: uiLanguage)
            localizedCountry = organization.localizedCountry(for: uiLanguage)
        } else {
            localizedTown = organization.town
            localizedCountry = LocalizedAddress.unknownCountry
        }
        memberCount = organization.members.count
        organizationWebsite = organization.organizationWebsite
        _isMapScrollLocked = isMapScrollLocked
    }

    fileprivate init(organizationType: OrganizationTypeEnum, // lower level initiatizer used by preview
                     status: OrganizationStatus,
                     localizedTown: String,
                     localizedCountry: String,
                     memberCount: Int,
                     organizationWebsite: URL?,
                     isMapScrollLocked: Binding<Bool>) {
        self.organizationType = organizationType
        self.status = status
        self.localizedTown = localizedTown
        self.localizedCountry = localizedCountry
        self.memberCount = memberCount
        self.organizationWebsite = organizationWebsite
        self._isMapScrollLocked = isMapScrollLocked
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // The same balloon as this organization's own (purple) marker on the map below.
            MapMarkerBalloon(mapOrganizationType: organizationType, isGhost: status.isGhost)
                .padding(.leading, 5)
                .padding(.trailing, 12) // the gap to the text

            VStack(alignment: .leading) {

                // location consisting of town and country
                Text(verbatim: layoutDirection == .leftToRight ?
                     "\(localizedTown), \(localizedCountry)" :
                     "\(localizedCountry) ,\(localizedTown)")
                .font(.subheadline)

                // "No longer active" or "May no longer be active", only for a ghost
                if let statusLabel = status.displayNameForAppUI {
                    Text(verbatim: statusLabel) // localized by the Data package
                        .font(.subheadline)
                        .italic()
                }

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
// Town and country are fixed English text here, while the app localizes them; the status line is localized in both.

#Preview {
    @Previewable @State var lockedClub1 = false
    @Previewable @State var lockedClub2 = true

    VStack(alignment: .leading, spacing: 20) {
        Divider()
        MapsViewInfo(organizationType: .club,
                             status: .active,
                             localizedTown: "Eindhoven",
                             localizedCountry: "Netherlands",
                             memberCount: 99,
                             organizationWebsite: URL(string: "https://www.fcDeGender.nl"),
                             isMapScrollLocked: $lockedClub1)
        Divider()
        MapsViewInfo(organizationType: .unknown,
                             status: .possiblyInactive,
                             localizedTown: "Gibsland",
                             localizedCountry: "United States",
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
