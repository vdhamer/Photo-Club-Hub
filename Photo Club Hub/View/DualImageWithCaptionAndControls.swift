//
//  DualImageMicroToolbar.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 10/05/2026.
//

import AudioToolbox // for AudioServicesPlaySystemSound
import SwiftUI // for View
import UIKit // for UINotificationFeedbackGenerator, UIDevice
import WebKit // for WKWebView

/// Trailing-edge widget in a member row: an sizable thumbnail backed by a 20-wide toolbar strip.
/// The toolbar contains a portfolio link button and, when a second image is available, a flip control
/// that toggles between the Featured image and the Photographer's own image.
/// `flipImageFlag` is a binding so taps here propagate back to the parent view/row.
struct DualImageWithCaptionAndControls: View {
    /// who is this about?
    var member: MemberPortfolio
    /// shared across many instances of DualImageWithCaptionAndControls
    let wkWebView: WKWebView
    let preferences: PreferencesStruct
    /// size of  square image
    let squareSize: CGFloat
    /// whether to show a caption below the image
    let caption: Bool
    /// current state of whether alternative image should be used
    @Binding var flipImageFlag: Bool
    /// from settings
    var preferenceForFeaturedImage: Bool

    var body: some View {
        let imageChoice = ImageChoice(member: member,
                                      isImageFlipped: flipImageFlag,
                                      preferenceForFeaturedImage: preferences.preferenceForFeaturedImage)
        HStack(alignment: .top) {
            VStack { // combines Image and Caption
                AsyncImage(url: imageChoice.url) { phase in
                    if let image = phase.image {
                        ZStack(alignment: .bottom) {
                            image // Displays the loaded image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: squareSize)
                        }
                    } else if phase.error != nil  ||
                                member.featuredImage == nil {
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
                .frame(width: squareSize, height: squareSize)
                .clipShape(RoundedRectangle(cornerRadius: squareSize * 0.15))
                .shadow(color: .accentColor.opacity(0.5), radius: 3)
                .allowsHitTesting(false)
                .overlay {
                    // elaborate code was a (failed) attempt to prevent reacting to taps slightly outside Image
                    // Color.clear is skipped by hit-testing; a near-invisible fill keeps the shape tappable
                    // while naturally restricting the tap area to the rounded-rectangle path.
                    Rectangle()
                        .fill(Color.white.opacity(0.001))
                        .onTapGesture {
                            if isThumbnailFlippable(member: member) {
                                flipImageFlag.toggle()
                            } else if UIDevice.isIPad {
                                AudioServicesPlaySystemSound(SystemSoundID(1521)) // "not allowed" tock on iPad
                            } else {
                                UINotificationFeedbackGenerator().notificationOccurred(.error)
                            }
                        }
                }
                if caption {
                    SinglePortfolioLinkView(destPortfolio: member, wkWebView: wkWebView) {
                        Text(verbatim: "\(member.roleDescriptionOfClubTown)")
                            .frame(width: squareSize, height: 35)
                            .multilineTextAlignment(.center)
                            .font(.caption)
                            .lineLimit(2)
                            .truncationMode(.middle)
                            .dynamicTypeSize( // block xLarge (etc) dynamic type size for layout reasons
                                ...DynamicTypeSize.large)
                    }
                    .tint(.primary)
                }
            }
            VStack {
                SinglePortfolioLinkView(destPortfolio: member, wkWebView: wkWebView) {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.accentColor)
                        .symbolRenderingMode(.palette)
                }
                .tint(.primary)
                Spacer()
                if isThumbnailFlippable(member: member) {
                    Text(imageFlippedIndicator())
                        .onTapGesture(perform: {
                            flipImageFlag.toggle()
                        })
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(.vertical, 5) // to align chevron with photographer name in MemberPortfolioRow
            .frame(width: 20, height: squareSize)
            .contentShape(Rectangle())
        }
    }

    private func chooseColor(defaultColor: Color, isDeceased: Bool) -> Color {
        isDeceased ? .deceasedColor : defaultColor
    }

    private func imageFlippedIndicator() -> Image {
        if flipImageFlag {
            return Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
        } else {
            return Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
        }
    }

    private func isThumbnailFlippable(member: MemberPortfolio) -> Bool {
        return member.photographer.photographerImage != nil &&
        member.photographer.photographerImage != member.featuredImage
    }
}

// MARK: - Previews

// Believe it or not, the following Previews actually works.
struct DualImageWithCaptionAndControls_Previews: PreviewProvider {

    // Wrapper is required so @State is an instance property, which SwiftUI needs
    // to wire up the binding correctly. @State static var does not work in previews.
    struct Wrapper: View {
        var member: MemberPortfolio
        @State var flipImageFlag = false
        let squareSize: CGFloat
        let caption: Bool

        var body: some View {
            NavigationStack {
                DualImageWithCaptionAndControls(member: member,
                                                wkWebView: WKWebView(),
                                                preferences: PreferencesStruct.defaultValue,
                                                squareSize: squareSize,
                                                caption: caption,
                                                flipImageFlag: $flipImageFlag,
                                                preferenceForFeaturedImage: true)
                .padding()
            }
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

        Wrapper(member: member, squareSize: 160, caption: true)
            .previewLayout(.sizeThatFits)

        Wrapper(member: member, squareSize: 80, caption: false)
            .previewLayout(.sizeThatFits)
    }
}
