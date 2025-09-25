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

struct MemberPortfolioRow: View {
    var member: MemberPortfolio
    @Environment(\.horizontalSizeClass) var horSizeClass
    let wkWebView: WKWebView
    fileprivate let of2 = String(localized: "of2", table: "PhotoClubHub.SwiftUI", comment: "<person> of <photo club>")
    let moc = PersistenceController.shared.container.viewContext

    var body: some View {
        SinglePortfolioLinkView(destPortfolio: member, wkWebView: wkWebView) {
            HStack(alignment: .top) {

                RoleStatusIconView(memberRolesAndStatus: member.memberRolesAndStatus)
                    .foregroundStyle(.memberPortfolioColor, .gray, .red) // red color is not used
                    .imageScale(.large)

                VStack(alignment: .leading) {
                    Text(verbatim: "\(member.photographer.fullNameFirstLast)")
                        .font(UIDevice.isIPad ? .title : .title2)
                        .tracking(1)
                        .allowsTightening(true)
                        .foregroundColor(chooseColor(
                            defaultColor: .accentColor,
                            isDeceased: member.photographer.isDeceased
                        ))

                    let localizedExpertiseResultLists = LocalizedExpertiseResultLists(moc: moc,
                                                            member.photographer.photographerExpertises)
                    Group {
                        if !localizedExpertiseResultLists.standard.list.isEmpty {
                            HStack(spacing: 3) {
                                Text(localizedExpertiseResultLists.standard.icon)
                                    .font(.footnote)
                                ForEach(localizedExpertiseResultLists.standard.list) { standardLKR in
                                    Text(standardLKR.localizedExpertise!.name + standardLKR.delimiterToAppend)
                                }
                            }
                        }

                        if !localizedExpertiseResultLists.nonstandard.list.isEmpty {
                            HStack(spacing: 3) {
                                Text(localizedExpertiseResultLists.nonstandard.icon)
                                    .font(.footnote)
                                ForEach(localizedExpertiseResultLists.nonstandard.list) { nonstandardLKR in
                                    Text(nonstandardLKR.id + nonstandardLKR.delimiterToAppend)
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
                AsyncImage(url: member.featuredImageThumbnail) { phase in
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
                .clipped()
                .border(TintShapeStyle() )
            } // HStack
        } // NavigationLink
    } // body of View

    func chooseColor(defaultColor: Color, isDeceased: Bool) -> Color {
        if isDeceased {
            return .deceasedColor
        } else {
            return defaultColor // .primary
        }
    }

}

 struct MemberPortfolioRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            let persistenceController = PersistenceController.shared // for Core Data
            let viewContext = persistenceController.container.viewContext

            let personName = PersonName(givenName: "Jan", infixName: "de", familyName: "Korte")
            let photographerOptionalFields = PhotographerOptionalFields()
            let photographer = Photographer.findCreateUpdate(context: viewContext,
                                                             personName: personName,
                                                             optionalFields: photographerOptionalFields)
            let organizationIdPlus = OrganizationIdPlus(fullName: "TestClub", town: "Location", nickname: "IgnoreMe")
            let organization = Organization.findCreateUpdate(context: viewContext,
                                                             organizationTypeEnum: OrganizationTypeEnum.club,
                                                             idPlus: organizationIdPlus,
                                                             coordinates: CLLocationCoordinate2D(
                                                                latitude: 0.0, longitude: 0.0),
                                                             optionalFields: OrganizationOptionalFields()
            )

            let member = MemberPortfolio.findCreateUpdate(bgContext: viewContext,
                                                          organization: organization,
                                                          photographer: photographer,
                                                          optionalFields: MemberOptionalFields()
            )
            MemberPortfolioRow(member: member, wkWebView: WKWebView())
        } .border(.blue, width: 1) .padding([.horizontal], 10)
    }
 }
