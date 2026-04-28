//
//  ReadmeCaption.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 26/04/2026.
//

import SwiftUI

struct ReadmeCaptionedImage: View {
    private let imageName: String
    private let imageSize: CGSize
    private let caption: LocalizedStringResource

    init(_ imageName: String, imageSize: CGSize, caption: LocalizedStringResource) {
        self.imageName = imageName
        self.imageSize = imageSize
        self.caption = caption
    }

    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .border(.gray, width: 1)
                .frame(width: imageSize.width, height: imageSize.height, alignment: .center)
            Text(caption)
                .font(.callout.italic())
                .frame(width: imageSize.width, alignment: .center)
                .padding(.bottom, 6)
        }
    }
}

// believe it or not, the following Preview does work
// Preview for ReadmeCaptionedImage
#Preview("ReadmeCaptionedImage", traits: .portrait) {
    Group {
        Divider()
        ReadmeCaptionedImage(
            "Maps",
            imageSize: CGSize(width: 260, height: 180),
            caption: LocalizedStringResource("Maps can be viewed in 3D.",
                                             table: "PhotoClubHub.Readme",
                                             comment: "Caption under example image in Features and Tips section")
        )
        ReadmeCaptionedImage(
            "Preferences",
            imageSize: CGSize(width: 260, height: 180),
            caption: LocalizedStringResource("This is the second caption.",
                                             table: "PhotoClubHub.Readme",
                                             comment: "Another caption example in Features and Tips section")
        )
        Divider()
    }
    .padding()
    .preferredColorScheme(.light)
}
