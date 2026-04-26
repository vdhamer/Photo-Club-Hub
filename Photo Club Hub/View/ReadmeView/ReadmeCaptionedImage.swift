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
