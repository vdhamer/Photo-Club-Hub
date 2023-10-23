//
//  SinglePortfolioLinkView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 22/10/2023.
//

import SwiftUI // for View
import WebKit // for WKWebView

struct SinglePortfolioLinkView<Content: View>: View {
    // https://www.hackingwithswift.com/books/ios-swiftui/custom-containers
    let destPortfolio: MemberPortfolio // portfolio to link to
    let content: () -> Content // what to show for this link

    @Environment(\.horizontalSizeClass) private var horSizeClass
    private let wkWebView = WKWebView() // TODO create once per image?? static not allowed. Pass as param?
    var photoClub: PhotoClub { destPortfolio.photoClub }

    var body: some View {
        NavigationLink(destination: SinglePortfolioView(url: destPortfolio.memberWebsite, webView: wkWebView)
            .navigationTitle(destPortfolio.photographer.fullNameFirstLast +
                             " @ " + nameOrShortName(horSizeClass: horSizeClass))
                .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)) {
            content()
        }
    }

    func nameOrShortName(horSizeClass: UserInterfaceSizeClass?) -> String {
        // full photo club name on iPad and iPhone 14 Plus or Pro Max only
        guard horSizeClass != nil else { return photoClub.shortName } // don't know size of display
        return (horSizeClass! == UserInterfaceSizeClass.compact) ? photoClub.shortName : photoClub.fullName
    }
}

 #Preview { // doesn't really work?
     let destPortfolio: MemberPortfolio = MemberPortfolio()
     return SinglePortfolioLinkView(destPortfolio: destPortfolio) {
         Text(verbatim: "Test Link")
     }
 }
