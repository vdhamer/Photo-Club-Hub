//
//  WhoIsWhoThumbnails.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 09/04/2024.
//

import SwiftUI
import WebKit

struct WhoIsWhoThumbnails: View {
    var photographer: Photographer // who is this about?
    var wkWebView: WKWebView // reusable WKWebView

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) { // 2nd row with images in photographer's "card"
            HStack { // to support multiple portfolio previews in one row
                ForEach(photographer.memberships.sorted(), id: \.id) { membership in
                    SinglePortfolioLinkView(destPortfolio: membership, wkWebView: wkWebView) {
                        VStack { // to combine image and caption
                            AsyncImage(url: membership.featuredImage) { phase in
                                if let image = phase.image {
                                    ZStack(alignment: .bottom) {
                                        image // Displays the loaded image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(height: 160)
                                    }
                                } else if phase.error != nil ||
                                            membership.featuredImage == nil {
                                    Image("Question-mark") // image indicates an error occurred
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } else {
                                    ZStack {
                                        Image("Tortoise") // placeholder while loading
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .opacity(0.4)
                                        ProgressView()
                                            .scaleEffect(x: 2, y: 2, anchor: .center)
                                            .blendMode(BlendMode.difference)
                                    }
                                }
                            }
                            .frame(width: 160, height: 160) // square
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .shadow(color: .accentColor.opacity(0.5), radius: 3)

                            Text(verbatim: "\(membership.roleDescriptionOfClubTown)")
                                .frame(width: 160, height: 35)
                                .font(.caption)
                                .lineLimit(2)
                                .truncationMode(.middle)
                                .dynamicTypeSize( // constrain impact of large dynamic type
                                    ...DynamicTypeSize.xLarge)
                        }
                        .border(.blue)
                    } // VStack to combine image and caption
                } // ForEach
            } // HStack to support multiple portfolio previews in one row
            .scrollTargetLayout() // unit of scrolling
        } // ScrollView
        .scrollTargetBehavior(.viewAligned(limitBehavior: .always)) // iOS 17 smart scrolling
//        .contentMargins(40, for: .scrollContent)
    }
}
