//
//  MemberPortfolioRow.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 17/02/2023.
//

import SwiftUI
import WebKit // for wkWebView

struct MemberPortfolioRow: View {
    var member: MemberPortfolio
    @Environment(\.horizontalSizeClass) var horSizeClass
    let wkWebView: WKWebView
    private let of2 = String(localized: "of2", comment: "<person> of <photo club>")

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
                    Text(verbatim: "\(member.roleDescriptionOfClubTown)")
                        .truncationMode(.tail)
                        .lineLimit(2)
                        .font(UIDevice.isIPad ? .headline : .subheadline)
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
                            Image("Embarrassed-snail") // Displays placeholder while loading
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

// struct MemberPortfolioRow_Previews: PreviewProvider {
//    static var previews: some View {
//        MemberPortfolioRow()
//    }
// }
