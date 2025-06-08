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

let maxKeywordsPerMember: Int = 2

struct MemberPortfolioRow: View {
    var member: MemberPortfolio
    @Environment(\.horizontalSizeClass) var horSizeClass
    let wkWebView: WKWebView
    fileprivate let of2 = String(localized: "of2", table: "Package", comment: "<person> of <photo club>")
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
                    ForEach(localizeSortAndClip(moc: moc, member.photographer.photographerKeywords)) { lExpertResult in
                        Text((lExpertResult.isStandard ? "🏵️ " : "🪲 ") + lExpertResult.name)
                            .font(.subheadline)
                    }
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
                    } else if phase.error != nil ||
                                member.featuredImageThumbnail == nil {
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

    fileprivate func localizeSortAndClip(moc: NSManagedObjectContext,
                                         _ photographerkeywords: Set<PhotographerKeyword>) -> [LocalizedKeywordResult] {
        // first translate keywords to appropriate language and make elements non-optional
        var result1 = [LocalizedKeywordResult]()
        for photographerKeyword in photographerkeywords where photographerKeyword.keyword_ != nil {
            result1.append(photographerKeyword.keyword_!.selectedLocalizedKeyword)
        }

        // then dsort based on selected language.  Has some special behavior for keywords without translation
        let result2: [LocalizedKeywordResult] = result1.sorted()
        let maxCount2 = result2.count // for ["keywordA", "keywordB", "keywordC"] maxCount is 3

        // insert delimeters where needed
        var result3 = [LocalizedKeywordResult]() // start with empty list
        var count: Int = 0
        for item in result2 {
            count += 1
            if count < maxCount2 { // turn this into ["keywordA,", "keywordB,", "keywordC"]
                result3.append(item) // accept appending "," to item
            } else {
                result3.append(LocalizedKeywordResult(localizedKeyword: item.localizedKeyword, id: item.id))
            }
        }

        // limit size to 3 displayed keywords
        if result3.count <= maxKeywordsPerMember { return result3 } // no clipping needed
        var result4 = [LocalizedKeywordResult]()
        for index in 1...maxKeywordsPerMember {
            result4.append(result3[index-1]) // copy the (aphabetically) first three LocalizedKeywordResult elements
        }
        let moreKeyword = Keyword.findCreateUpdateStandard(context: moc,
                                                           id: String(localized: "Too many expertises", table: "HTML",
                                                                      comment: "Shown if photographer has >3 keywords"),
                                                           name: [],
                                                           usage: [])
        let moreLocalizedKeyword: LocalizedKeywordResult = moreKeyword.selectedLocalizedKeyword
        result4.append(LocalizedKeywordResult(localizedKeyword: moreLocalizedKeyword.localizedKeyword,
                                              id: moreKeyword.id,
                                              customHint: customHint(localizedKeywordResults: result3)))

        return result4
    }

    fileprivate func customHint(localizedKeywordResults: [LocalizedKeywordResult]) -> String {
        var hint: String = ""

        for localizedKeywordResult in localizedKeywordResults {
            if localizedKeywordResult.localizedKeyword != nil {
                hint.append("🏵️ " + localizedKeywordResult.localizedKeyword!.name + " ")
            } else {
                hint.append("🪲 " + localizedKeywordResult.id + " ")
            }
        }

        return hint.trimmingCharacters(in: CharacterSet(charactersIn: " "))
    }
}

 struct MemberPortfolioRow_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController.shared // for Core Data
        let viewContext = persistenceController.container.viewContext
        let personName = PersonName(givenName: "Jan", infixName: "de", familyName: "Korte")
        let optionalFields = PhotographerOptionalFields()
        let photographer = Photographer.findCreateUpdate(context: viewContext,
                                                     personName: personName,
                                                     optionalFields: optionalFields)
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
    }
 }
