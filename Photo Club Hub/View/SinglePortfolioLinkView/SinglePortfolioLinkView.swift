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
    let wkWebView: WKWebView // pass as param to avoid creating this lots of times
    let content: () -> Content // what to show for this link

    @Environment(\.horizontalSizeClass) fileprivate var horSizeClass
    var organization: Organization { destPortfolio.organization }

    var body: some View {
        NavigationLink(destination: SinglePortfolioView(url: destPortfolio.level3URL, webView: wkWebView)
            .navigationTitle(destPortfolio.photographer.fullNameFirstLast +
                             " @ " + fullNameOrNickName(horSizeClass: horSizeClass))
            .navigationBarTitleDisplayMode(NavigationBarItem.TitleDisplayMode.inline)) {
                content()
            }
    }

    func fullNameOrNickName(horSizeClass: UserInterfaceSizeClass?) -> String {
        // full photo club name on iPad and iPhone 14 Plus or Pro Max only
        guard horSizeClass != nil else { return organization.nickName } // don't know size of display
        return (horSizeClass! == UserInterfaceSizeClass.compact) ? organization.nickName : organization.fullName
    }
}

#Preview { // doesn't really work
    let destPortfolio: MemberPortfolio = MemberPortfolio()
    let wkWebView = WKWebView()
    return SinglePortfolioLinkView(destPortfolio: destPortfolio, wkWebView: wkWebView) {
        Text(verbatim: "Test Link")
    }
}
