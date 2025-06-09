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

                    let localizedKeywordResultLists = localizeSortAndClip(moc: moc,
                                                                          member.photographer.photographerKeywords)
                    Group {
                        if !localizedKeywordResultLists.standard.list.isEmpty {
                            HStack(spacing: 3) {
                                Text(localizedKeywordResultLists.standard.icon)
                                    .font(.footnote)
                                ForEach(localizedKeywordResultLists.standard.list) { standardLKR in
                                    Text(standardLKR.localizedKeyword!.name + standardLKR.delimiterToAppend)
                                }
                            }
                        }

                        if !localizedKeywordResultLists.nonstandard.list.isEmpty {
                            HStack(spacing: 3) {
                                Text(localizedKeywordResultLists.nonstandard.icon)
                                    .font(.footnote)
                                ForEach(localizedKeywordResultLists.nonstandard.list) { nonstandardLKR in
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

    fileprivate func localizeSortAndClip(moc: NSManagedObjectContext, _ photographerKeywords: Set<PhotographerKeyword>)
    -> LocalizedExpertiseResultLists {

        // Step 1. Translate keywords to appropriate language
        var translated: [LocalizedKeywordResult] = [] // start with empty array
        for photographerKeyword in photographerKeywords {
            translated.append(photographerKeyword.keyword.selectedLocalizedKeyword) // choose most suitable language
        }

        // Step 2. Sort based on selected language.  Has special behavior for keywords without translation
        let sorted: [LocalizedKeywordResult] = translated.sorted() // note dedicated LocalizedKeywordResult.<() function

        // Step 3. Clip size to maxKeywordsPerMember keywords
        var clipped: [LocalizedKeywordResult] = [] // start with empty array
        if sorted.count > 0 {
            for index in 0...min(maxKeywordsPerMember-1, sorted.count-1) {
                clipped.append(sorted[index]) // copy the first few sorted LocalizedKeywordResult elements
            }
        }

        // Step 4. Split list of photographer's expertises into 2 parts: standard and nonStandard
        var standard: [LocalizedKeywordResult] = [] // start with two empty arrays
        var nonStandard: [LocalizedKeywordResult] = []
        for item in clipped {
            if item.isStandard {
                standard.append(item)
            } else {
                nonStandard.append(LocalizedKeywordResult(localizedKeyword: item.localizedKeyword, id: item.id))
            }
        }

        // Step 6. remove delimeter after last element
        if sorted.count > maxKeywordsPerMember { // if list overflows, add a warning
            let moreKeyword = Keyword.findCreateUpdateNonStandard(
                                        context: moc,
                                        id: String(localized: "Too many expertises",
                                                   table: "Localizable",
                                                   comment: "Shown when too many expertises are found"),
                                        name: [],
                                        usage: [] )
            let moreLocalizedKeyword: LocalizedKeywordResult = moreKeyword.selectedLocalizedKeyword
            nonStandard.append(LocalizedKeywordResult(localizedKeyword: moreLocalizedKeyword.localizedKeyword,
                                                      id: moreKeyword.id,
                                                      customHint: customHint(localizedKeywordResults: sorted)))
        }

        // Step 6. remove delimeter after last element
        if !standard.isEmpty {
            standard[standard.count-1].delimiterToAppend = ""
        }
        if !nonStandard.isEmpty {
            nonStandard[nonStandard.count-1].delimiterToAppend = ""
        }

        return LocalizedExpertiseResultLists(standardList: standard, nonstandardList: nonStandard)
    }

    fileprivate func customHint(localizedKeywordResults: [LocalizedKeywordResult]) -> String {
        var hint: String = ""
        let temp = LocalizedExpertiseResultLists(standardList: [], nonstandardList: [])

        for localizedKeywordResult in localizedKeywordResults {
            if localizedKeywordResult.localizedKeyword != nil {
                hint.append(temp.standard.icon + " " + localizedKeywordResult.localizedKeyword!.name + " ")
            } else {
                hint.append(temp.nonstandard.icon + " " + localizedKeywordResult.id + " ")
            }
        }

        return hint.trimmingCharacters(in: CharacterSet(charactersIn: " "))
    }

    fileprivate func getIconString(standard: Bool) -> String {
        let temp = LocalizedExpertiseResultLists(standardList: [], nonstandardList: [])
        return standard ? temp.standard.icon : temp.nonstandard.icon
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
