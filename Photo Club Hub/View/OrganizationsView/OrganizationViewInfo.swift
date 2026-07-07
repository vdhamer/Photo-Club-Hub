//
//  OrganizationViewInfo.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 30/12/2021.
//

import SwiftUI // for View

/// Type-icon on the left, few rows of text on the right, tapable lock symbol. Called from FilteredOrganizationView.
@MainActor
struct OrganizationViewInfo: View {

    @Environment(\.layoutDirection) var layoutDirection // .leftToRight or .rightToLeft

    let iconSystemName: String // SF Symbol name for organizationType
    let isUnknownType: Bool // true when organizationType is "unknown"
    let localizedTown: String
    let localizedCountry: String
    let memberCount: Int
    let organizationWebsite: URL?
    @Binding var isMapScrollLocked: Bool // bound so the lock toggle writes back to the Organization

    init(organization: Organization) { // higher level initializer for production
        iconSystemName = systemName(organizationType: organization.organizationType, circleNeeded: true)
        isUnknownType = organization.organizationType.isUnknown
        localizedTown = organization.localizedTown
        localizedCountry = organization.localizedCountry
        memberCount = organization.members.count
        organizationWebsite = organization.organizationWebsite
        _isMapScrollLocked = Binding(
            get: { organization.isMapScrollLocked },
            set: { organization.isMapScrollLocked = $0 }
        )
    }

    fileprivate init(iconSystemName: String, // lower level initiatizer used by preview
                     isUnknownType: Bool,
                     localizedTown: String,
                     localizedCountry: String,
                     memberCount: Int,
                     organizationWebsite: URL?,
                     isMapScrollLocked: Binding<Bool>) {
        self.iconSystemName = iconSystemName
        self.isUnknownType = isUnknownType
        self.localizedTown = localizedTown
        self.localizedCountry = localizedCountry
        self.memberCount = memberCount
        self.organizationWebsite = organizationWebsite
        self._isMapScrollLocked = isMapScrollLocked
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image(systemName: iconSystemName) // icon for organizationType
            .foregroundStyle(.white, .yellow, // .yellow (secondary color) not actually used
                             isUnknownType ? .red : .accentColor)
            .symbolRenderingMode(.palette)
            .font(.largeTitle)
            .padding(.horizontal, 5)

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

// Believe it or not, these previews actually works.
#Preview {
    @Previewable @State var lockedWaalre = false
    @Previewable @State var lockedDenDungen = true

    VStack(alignment: .leading, spacing: 20) {
        Divider()
        OrganizationViewInfo(iconSystemName: "camera.circle.fill",
                             isUnknownType: false,
                             localizedTown: "Waalre",
                             localizedCountry: "Netherlands",
                             memberCount: 24,
                             organizationWebsite: URL(string: "https://www.fotogroepwaalre.nl"),
                             isMapScrollLocked: $lockedWaalre)
        Divider()
        OrganizationViewInfo(iconSystemName: "questionmark.circle.fill",
                             isUnknownType: true,
                             localizedTown: "Nieuw Amsterdam",
                             localizedCountry: "Verenigde Staten",
                             memberCount: 0,
                             organizationWebsite: nil,
                             isMapScrollLocked: $lockedDenDungen)
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
