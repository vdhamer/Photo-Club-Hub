//
//  MemberPortfolioRow.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/02/2023.
//

import SwiftUI
import WebKit // for wkWebView
import CoreLocation // for CLLocationCoordinate2D
import CoreData // for NSManagedObjectContext

/// A single row representing a MemberPortfolio (aka Photographer in the context of a particular Club).
///
/// Displays the member's role/status icon, name, expertise tags, club/town role description,
/// and a thumbnail image that can toggle between featured and photographer images.
/// Tapping the thumbnail toggles the show image variant if both variants are available.
/// The entire row is wrapped in a navigation link to the member's detailed portfolio view.
struct MemberPortfolioRow: View {
    /// The member portfolio model used to populate this row.
    var member: MemberPortfolio
    /// Shared `WKWebView` instance used by downstream views for web content.
    let wkWebView: WKWebView
    /// Localized connector text used as '<person> of <photo club>'.
    private let of2 = String(localized: "of2", table: "PhotoClubHub.SwiftUI", comment: "<person> of <photo club>")
    /// Core Data context used to resolve localized expertise lists.
    let moc = PersistenceController.shared.container.viewContext
    /// `flipImageFlag` is flipped by tapping on image. It reverses the image to an alternative image.
    @State var flipImageFlag: Bool = false

    /// Builds the row content with role icon, identity, expertise, role/club line, and image.
    var body: some View {
        SinglePortfolioLinkView(destPortfolio: member, wkWebView: wkWebView) {
            HStack(alignment: .top) {

                RoleStatusIconView(memberRolesAndStatus: member.memberRolesAndStatus)
                    .foregroundStyle(.memberPortfolioColor, .gray, .red) // red color is not used
                    .imageScale(.large)

                VStack(alignment: .leading) {
                    HStack {
                        Text(verbatim: "\(member.photographer.fullNameFirstLast)")
                            .font(UIDevice.isIPad ? .title : .title2)
                            .tracking(1)
                            .allowsTightening(true)
                        Spacer()
                        Text(imageFlippedIndicator())
                    }
                    .foregroundColor(chooseColor(
                        defaultColor: .accentColor,
                        isDeceased: member.photographer.isDeceased
                    ))

                    let localizedExpertiseResultLists = LocalizedExpertiseResultLists(moc: moc,
                                                            member.photographer.photographerExpertises)
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

                        if !localizedExpertiseResultLists.temporary.list.isEmpty { // list  any "temporary" expertises
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

                    Text(verbatim: "\(member.roleDescriptionOfClubTown)")
                        .truncationMode(.tail)
                        .lineLimit(2)
                        .font(UIDevice.isIPad ? .subheadline : .caption)
                        .foregroundColor(member.photographer.isDeceased ?
                            .deceasedColor : .primary)
                }
                Spacer()
                AsyncImage(url: chooseImageURL(member: member, isImageFlipped: flipImageFlag).url) { phase in
                    if let image = phase.image {
                        image // Displays the loaded image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if phase.error != nil {
                        Image("Question-mark") // Displays image indicating an error occurred
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        ZStack {
                            Image("Tortoise") // Displays placeholder while loading
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .opacity(0.4)
                            ProgressView()
                                .scaleEffect(x: 2, y: 2, anchor: .center)
                                .blendMode(BlendMode.difference)
                        }
                    }
                }
                .frame(width: 80, height: 80)
                .border(chooseColor(defaultColor: .accentColor, isDeceased: member.photographer.isDeceased))
                .onTapGesture { // overrules tap gestures on parent view
                    flipImageFlag.toggle() // toggle between featuredImage and photographerImage
                }
            } // HStack
        } // NavigationLink
    } // body of View

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

    private func imageFlippedIndicator() -> String {
        flipImageFlag ? " ↻" : ""
    }

}

// Believe it or not, the following Preview actually works
struct MemberPortfolioRow_Previews: PreviewProvider { // this preview actually works!
    static var previews: some View {
        Group {
            let persistenceController = PersistenceController.shared // for Core Data
            let viewContext = persistenceController.container.viewContext

            let personName = PersonName(givenName: "Jan", infixName: "de", familyName: "Korte")
            let photographerOptionalFields = PhotographerOptionalFields(isDeceased: true)
            let photographer = Photographer.findCreateUpdate(
                context: viewContext,
                personName: personName,
                optionalFields: photographerOptionalFields
            )

            let organizationIdPlus = OrganizationIdPlus(fullName: "TestClub", town: "Location", nickname: "IgnoreMe")
            let organization = Organization.findCreateUpdate(
                context: viewContext,
                organizationTypeEnum: OrganizationTypeEnum.club,
                idPlus: organizationIdPlus,
                coordinates: CLLocationCoordinate2D(
                    latitude: 0.0, longitude: 0.0),
                optionalFields: OrganizationOptionalFields()
            )

            let memberRolesAndStatus = MemberRolesAndStatus(roles: [.chairman: true],
                                                            status: [.former: true])
            let member = MemberPortfolio.findCreateUpdate(
                bgContext: viewContext,
                organization: organization,
                photographer: photographer,
                optionalFields: MemberOptionalFields(
                    memberRolesAndStatus: memberRolesAndStatus
                )
            )
            MemberPortfolioRow(member: member, wkWebView: WKWebView())
        } .border(.blue, width: 1) .padding([.horizontal], 10)
    }
}
