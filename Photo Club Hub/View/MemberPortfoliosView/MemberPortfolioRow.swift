//
//  MemberPortfolioRow.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/02/2023.
//

import SwiftUI      // for View, etc.
import CoreLocation // for CLLocationCoordinate2D
import CoreData     // for NSManagedObjectContext
import Photo_Club_Hub_Data // for types like MemberPortfolio

/// A single row representing a MemberPortfolio (aka Photographer in the context of a particular Club).
///
/// Only guards against unusable memberships; `MemberPortfolioRowContent` draws the row.
struct MemberPortfolioRow: View {
    /// The member portfolio used to populate this row.
    @ObservedObject var member: MemberPortfolio
    /// Parent-owned selection: set when the text/icon area is tapped, triggering navigation to the member's
    /// portfolio via the `navigationDestination(item:)` registered in `MemberPortfolioView`.
    @Binding var selectedPortfolio: MemberPortfolio?

    /// Deliberately reads nothing from `member` (#874).
    /// Deleting memberships makes SwiftUI rebuild the `List` synchronously, inside the save that deletes them:
    /// the parent's `ForEach` still holds its array from before the delete,
    /// so `init` runs on memberships whose relationships were just nullified.
    /// Today the deleter is pull-to-refresh, which wipes the store; later it is the pruning of obsolete records
    /// (Photo-Club-Hub-Data#39). Deleting on a background context does not avoid this:
    /// merging that save into the view context notifies the observing views on the main thread in the same way.
    /// The parent's `isUsable` filter cannot help, because the parent's body has not run again yet.
    init(member: MemberPortfolio, selectedPortfolio: Binding<MemberPortfolio?>) {
        self.member = member
        self._selectedPortfolio = selectedPortfolio
    }

    /// Skips a membership that has been deleted (#802) or has no photographer (#874), instead of tripping the
    /// `photographer` and `organization` accessors.
    /// The row observes `member`, so deleting it is precisely what makes SwiftUI re-run this body,
    /// while the parent's filtered `ForEach` has not dropped the row yet.
    var body: some View {
        if member.isUsable, let photographer = member.photographer_ {
            MemberPortfolioRowContent(member: member,
                                      photographer: photographer,
                                      selectedPortfolio: $selectedPortfolio)
        }
    }

}

/// The content of a `MemberPortfolioRow`, created only once the row has checked that `member` is usable and
/// has a photographer.
///
/// Displays the member's role/status icon, name, expertise tags, club/town role description,
/// and a thumbnail image that can toggle between featured and photographer images.
/// Tapping the thumbnail toggles the shown image variant if both variants are available.
/// Only `MemberPortfolioRow` creates it; it is not `private` so that `DeletedMembershipViewsTest` can reach it.
struct MemberPortfolioRowContent: View {
    /// The member portfolio model used to populate this row.
    @ObservedObject var member: MemberPortfolio
    /// The membership's photographer, passed in by `MemberPortfolioRow` after it has checked it (#874).
    /// Observed separately because name, deceased status and expertise tags live on the Photographer,
    /// not on the membership: during pull-to-refresh another club's file can add expertises after this row is drawn,
    /// and observing `member` does not notice that (#862).
    @ObservedObject var photographer: Photographer
    /// Parent-owned selection: set when the text/icon area is tapped, triggering navigation to the member's
    /// portfolio via the `navigationDestination(item:)` registered in `MemberPortfolioView`.
    @Binding var selectedPortfolio: MemberPortfolio?
    /// Localized connector text used as '<person> of <photo club>'.
    private let of2 = String(localized: "of2", table: "PhotoClubHub.SwiftUI", comment: "<person> of <photo club>")
    /// Core Data context used to resolve localized expertise lists.
    let moc = PersistenceController.shared.container.viewContext
    /// `flipImageFlag` is flipped by tapping on image. It reverses the image to an alternative image.
    @State var flipImageFlag: Bool = false
    /// Provides access to user preferences (e.g. settings.preferenceForFeaturedImage) to this view and descendants.
    @StateObject var settingsModel = SettingsViewModel.shared

    /// Builds the row content with role icon, identity, expertise, role/club line, and image.
    ///
    /// Repeats the check in `MemberPortfolioRow.body`, because this view observes `member` itself:
    /// deleting it re-runs this body directly, without passing through the row's body (#874).
    var body: some View {
        if member.isUsable && member.photographer_ != nil {
            rowContent
        }
    }

    @ViewBuilder private var rowContent: some View {
        HStack(alignment: .top) { // total view content

            Button {
                selectedPortfolio = member
            } label: { // Button (not NavigationLink) avoids a chevron
                HStack(alignment: .top) { // everything to left of Image: icon + several lines of Text

                    // icon showing any special role
                    RoleStatusIconView(memberRolesAndStatus: member.memberRolesAndStatus) // icon
                        .foregroundStyle(.clubsColor, .gray, .red) // red color is not used
                        .imageScale(.large)

                    // name of photographer
                    VStack(alignment: .leading) {
                        Text(verbatim: "\(photographer.fullNameFirstLast)") // photographer's name
                            .font(UIDevice.isIPad ? .title : .title2)
                            .tracking(1)
                            .allowsTightening(true)
                            .foregroundStyle(chooseColor(
                                defaultColor: .accentColor,
                                isDeceased: photographer.isDeceased
                            ))

                        // expertises
                        let localizedExpertiseResultLists =
                            LocalizedExpertiseResultLists(moc: moc,
                                                          photographer.photographerExpertises)
                        Group {
                            if !localizedExpertiseResultLists.supported.list.isEmpty { // list any supported expertises
                                HStack(spacing: 3) {
                                    Text(localizedExpertiseResultLists.supported.icon)
                                        .font(.footnote)
                                    ForEach(localizedExpertiseResultLists.supported.list) { supportedLER in
                                        Text(supportedLER.localizedExpertise!.name + supportedLER.delimiterToAppend)
                                    }
                                }
                            }

                            if !localizedExpertiseResultLists.temporary.list.isEmpty { // list any temporary expertises
                                HStack(spacing: 3) {
                                    Text(localizedExpertiseResultLists.temporary.icon)
                                        .font(.footnote)
                                    ForEach(localizedExpertiseResultLists.temporary.list) { temporaryLKR in
                                        Text(temporaryLKR.id + temporaryLKR.delimiterToAppend)
                                    }
                                }
                            }
                        }
                        .font(.subheadline)
                        .lineLimit(1)
                        .truncationMode(.tail)

                        // roles
                        Text(verbatim: "\(member.roleDescriptionOfClubTown)")
                            .truncationMode(.tail)
                            .lineLimit(2)
                            .font(UIDevice.isIPad ? .subheadline : .caption)
                            .foregroundStyle(photographer.isDeceased ?
                                .deceasedColor : .primary)
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            DualImageWithCaptionAndControls(member: member,
                                            photographer: photographer,
                                            settings: settingsModel.settings,
                                            squareSize: 80,
                                            caption: false,
                                            flipImageFlag: $flipImageFlag,
                                            selectedPortfolio: $selectedPortfolio)

        } // HStack
    } // rowContent

    /// Chooses a color based on deceased status, otherwise returns the provided default.
    /// - Parameters:
    ///   - defaultColor: The color to use when the person is not deceased.
    ///   - isDeceased: Whether the person is marked as deceased.
    /// - Returns: `.deceasedColor` when deceased, else `defaultColor`.
    private func chooseColor(defaultColor: Color, isDeceased: Bool) -> Color {
        if isDeceased {
            return .deceasedColor
        } else {
            return defaultColor // .primary
        }
    }

}

// MARK: - Previews

// Believe it or not, the following Preview actually works.

#Preview {
    let persistenceController = PersistenceController.shared // for Core Data
    let viewContext = persistenceController.container.viewContext

    let personName = PersonName(givenName: "Jan", infixName: "de", familyName: "Korte")
    let photographerOptionalFields = PhotographerOptionalFields(
        isDeceased: true,
        photographerImage: URL(string: "https://thispersondoesnotexist.com")
        )
    let photographer = Photographer.findCreateUpdate(
        context: viewContext,
        personName: personName,
        optionalFields: photographerOptionalFields
    )

    let organizationIdPlus = OrganizationIdPlus(fullName: "TestClub",
                                                town: "SomeLocation",
                                                nickname: "IgnoreMe")
    let organization = Organization.findCreateUpdate(
        context: viewContext,
        organizationTypeEnum: OrganizationTypeEnum.club,
        idPlus: organizationIdPlus,
        coordinates: CLLocationCoordinate2D(
            latitude: 0.0, longitude: 0.0),
        optionalFields: OrganizationOptionalFields()
    )

    let memberRolesAndStatus = MemberRolesAndStatus(roles: [.treasurer: true],
                                                    status: [.former: true])
    let member = MemberPortfolio.findCreateUpdate(
        bgContext: viewContext,
        organization: organization,
        photographer: photographer,
        optionalFields: MemberOptionalFields(
            featuredImage: URL(string: "https://picsum.photos/500"),
            featuredImageThumbnail: URL(string: "https://picsum.photos/200"),
            level3URL: URL(string: "https://www.example.com"),
            memberRolesAndStatus: memberRolesAndStatus
        )
    )
    MemberPortfolioRow(member: member, selectedPortfolio: .constant(nil))
        .border(.blue, width: 1) .padding([.horizontal], 10)
}
