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

    @ObservedObject var filteredOrganization: Organization // observes changes (e.g. isMapScrollLocked toggle)

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image(systemName: systemName(organizationType: filteredOrganization.organizationType,
                                         circleNeeded: true) // icon for organizationType
            )
            .foregroundStyle(.white, .yellow, // .yellow (secondary color) not actually used
                             filteredOrganization.organizationType.isUnknown ? .red : .accentColor)
            .symbolRenderingMode(.palette)
            .font(.largeTitle)
            .padding(.horizontal, 5)

            VStack(alignment: .leading) {

                // location consisting of town and country
                Text(verbatim: layoutDirection == .leftToRight ?
                     "\(filteredOrganization.localizedTown), \(filteredOrganization.localizedCountry)" :
                     "\(filteredOrganization.localizedCountry) ,\(filteredOrganization.localizedTown)")
                .font(.subheadline)

                // number of members (if applicable)
                if filteredOrganization.members.count > 0 { // hide for museums and clubs without members
                    Text("\(filteredOrganization.members.count) members (inc. ex-members)",
                         tableName: "PhotoClubHub.SwiftUI",
                         comment: "<count> members (including all types of members) within photo club")
                    .font(.subheadline)
                }

                // URL to existing club/museum website
                if let website: URL = filteredOrganization.organizationWebsite {
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
                    openCloseSound(openClose: filteredOrganization.isMapScrollLocked ? .close : .open)
                    filteredOrganization.isMapScrollLocked.toggle()
                },
                label: {
                    HStack { // to make background color clickable too
                        LockAnimationView(locked: filteredOrganization.isMapScrollLocked)
                    }
                    .frame(width: 60, height: 60)
                    .contentShape(Rectangle())
                }
            )
            .buttonStyle(.plain) // to avoid entire List element to be clickable
        }
        .padding(.all, 0)
    }
}
