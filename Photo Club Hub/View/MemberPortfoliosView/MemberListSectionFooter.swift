//
//  MemberListSectionFooter.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 10/05/2026.
//

import SwiftUI
import CoreLocation // for CLLocationCoordinate2D in preview

/// Section footer for the Members list showing how many members are visible after filtering.
/// Displays "N member(s) shown" or "N of M member(s) shown" when a search filter reduces the count,
/// followed by the club's data-source URL (host + path only).
/// Used by both `FilteredMemberPortfoliosView2627` and `FilteredMemberPortfoliosView1718`.
struct MemberListSectionFooter: View {
    var filtCount: Int // number of items in filtered list
    var unfiltCount: Int // number of items in unfiltered list
    var organization: Organization? // optional because we copy this from first member in the photoClub collection
    let member = String(localized: "member_",
                        table: "PhotoClubHub.SwiftUI",
                        comment: "Statistics at end of section of FilteredMemberPortfoliosView")
    let members = String(localized: "members",
                         table: "PhotoClubHub.SwiftUI",
                         comment: "Statistics at end of section of FilteredMemberPortfoliosView")
    let shown = String(localized: "shown",
                       table: "PhotoClubHub.SwiftUI",
                       comment: "X member(s) shown (due to various forms of filtering)")
    let of1 = String(localized: "of1",
                     table: "PhotoClubHub.SwiftUI",
                     comment: "X of Y portfolio(s) shown (due to various forms of filtering)")

    var body: some View {
        HStack {
            Spacer()
            VStack {
                if filtCount < unfiltCount {
                    Text(verbatim: // verbatim keeps these pretty empty strings out of the String Catalogue
                         "\(filtCount) \(filtCount==1 ? member : members) (\(of1) \(unfiltCount)) \(shown).")
                } else {
                    Text(verbatim:
                         "\(unfiltCount) \(unfiltCount==1 ? member : members) \(shown).")
                }
                if organization != nil,
                   organization!.level2URL != nil,
                   organization!.level2URL!.host != nil,
                   organization!.level2URL!.scheme != nil {
                        Text(String(localized: """
                                               Data source: \(organization!.level2URL!.scheme!)://\
                                               \(organization!.level2URL!.host!)\
                                               \(organization!.level2URL!.path)/
                                               """,
                            table: "PhotoClubHub.SwiftUI",
                            comment: "Section footer text Portfolios screen"))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
                .font(.subheadline)
                .dynamicTypeSize( // constrain impact of large dynamic type
                    ...DynamicTypeSize.large) // this is just supposed to be a footer, so don't want it too big
                .lineLimit(2)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

// MARK: - Previews

// Believe it or not, the following Previews actually work
struct MemberListSectionFooter_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext
        let organization = Organization.findCreateUpdate(
            context: viewContext,
            organizationTypeEnum: OrganizationTypeEnum.club,
            idPlus: OrganizationIdPlus(fullName: "Test Photo Club", town: "Eindhoven", nickname: "TestClub"),
            coordinates: CLLocationCoordinate2D(latitude: 51.4, longitude: 5.5),
            optionalFields: OrganizationOptionalFields(
                level2URL: URL(string: "https://www.example.com/members/")
            )
        )

        Group {
            MemberListSectionFooter(filtCount: 7, unfiltCount: 7,
                                    organization: nil)
                .previewDisplayName("All shown, no URL")
            MemberListSectionFooter(filtCount: 3, unfiltCount: 7,
                                    organization: nil)
                .previewDisplayName("Filtered, no URL")
            MemberListSectionFooter(filtCount: 7, unfiltCount: 7,
                                    organization: organization)
                .previewDisplayName("All shown, with data-source URL")
        }
        .padding()
    }
}
