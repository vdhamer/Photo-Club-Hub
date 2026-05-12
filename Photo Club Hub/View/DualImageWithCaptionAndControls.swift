//
//  DualImageMicroToolbar.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 10/05/2026.
//

import SwiftUI
import WebKit // for WKWebView

/// Trailing-edge widget in a member row: an 80×80 thumbnail backed by a 20×80 toolbar strip.
/// The toolbar contains a portfolio link button and, when two images are available, a flip indicator
/// that toggles between the featured image and the photographer's own image.
/// `flipImageFlag` is a binding so taps here propagate back to the parent row.
struct DualImageWithCaptionAndControls: View {
    var member: MemberPortfolio
    let wkWebView: WKWebView
    @Binding var flipImageFlag: Bool
    var preferenceForFeaturedImage: Bool

    var body: some View {
        let imageChoice = ImageChoice(member: member,
                                      isImageFlipped: flipImageFlag,
                                      preferenceForFeaturedImage: preferenceForFeaturedImage)
        HStack(alignment: .top) {
            AsyncImage(url: imageChoice.url) { phase in
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
            .clipped()
            .contentShape(Rectangle())
            .onTapGesture(perform: {
                if isThumbnailFlippable() {
                    flipImageFlag.toggle()
                }
            })

            VStack {
                SinglePortfolioLinkView(destPortfolio: member, wkWebView: wkWebView) { EmptyView() }
                Spacer()
                if isThumbnailFlippable() {
                    Text(imageFlippedIndicator())
                        .onTapGesture(perform: {
                            flipImageFlag.toggle()
                        })
                        .foregroundStyle(Color.accentColor)
                }
            }
            .frame(width: 20, height: 80)
        }
    }

    private func chooseColor(defaultColor: Color, isDeceased: Bool) -> Color {
        isDeceased ? .deceasedColor : defaultColor
    }

    private func imageFlippedIndicator() -> String {
        flipImageFlag ? "↺" : "↻"
    }

    private func isThumbnailFlippable() -> Bool {
        return member.photographer.photographerImage != nil &&
                           member.photographer.photographerImage != member.featuredImage
    }
}

// MARK: - Previews

// Believe it or not, the following Preview actually works.
struct MemberImageMiniToolbar_Previews: PreviewProvider {

    // Wrapper is required so @State is an instance property, which SwiftUI needs
    // to wire up the binding correctly. @State static var does not work in previews.
    struct Wrapper: View {
        var member: MemberPortfolio
        @State var flipImageFlag = false

        var body: some View {
            DualImageWithCaptionAndControls(member: member,
                                            wkWebView: WKWebView(),
                                            flipImageFlag: $flipImageFlag,
                                            preferenceForFeaturedImage: true)
                .padding()
        }
    }

    static var previews: some View {
        let viewContext = PersistenceController.shared.container.viewContext

        let photographer = Photographer.findCreateUpdate(
            context: viewContext,
            personName: PersonName(givenName: "Jan", infixName: "de", familyName: "Korte"),
            optionalFields: PhotographerOptionalFields(
                photographerImage: URL(string: "https://thispersondoesnotexist.com")
            )
        )
        let organization = Organization.findCreateUpdate(
            context: viewContext,
            organizationTypeEnum: OrganizationTypeEnum.club,
            idPlus: OrganizationIdPlus(fullName: "TestClub", town: "SomeLocation", nickname: "IgnoreMe"),
            optionalFields: OrganizationOptionalFields()
        )
        let member = MemberPortfolio.findCreateUpdate(
            bgContext: viewContext,
            organization: organization,
            photographer: photographer,
            optionalFields: MemberOptionalFields(
                featuredImage: URL(string: "https://picsum.photos/500"),
                featuredImageThumbnail: URL(string: "https://picsum.photos/200"),
                level3URL: URL(string: "https://www.example.com")
            )
        )

        Wrapper(member: member)
            .previewLayout(.sizeThatFits)
    }
}
