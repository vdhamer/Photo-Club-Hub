//
//  SinglePortfolioView.swift
//  Photo Club Hub
//
//  Created by Peter van den Hamer on 03/01/2022.
//

import SwiftUI
import WebKit // for UIViewRepresentable protocol and WKWebView

// There will be multiple MemberViews?
struct SinglePortfolioView: UIViewRepresentable {

    @State var url: URL
    // wrapper from UIKit to a SwiftUI view
    typealias UIViewType = WKWebView
    @State var webView: WKWebView // sharing WKWebView to avoid error messages if webView goes out of scope

    func makeUIView(context: Context) -> WKWebView {
         return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }

}

// only visible when canvas is simulating/running
struct SinglePortfolioView_Previews: PreviewProvider {
    static var webView = WKWebView()
    static var url: URL = URL(string: FotogroepWaalreMembersProvider.baseURL + "Peter_van_den_Hamer/")!

    static var previews: some View {
        NavigationStack {
            SinglePortfolioView(url: url, webView: webView)
                .previewLayout(.sizeThatFits)
                .navigationBarTitle(String("SinglePortfolioView")) // avoid localization
                .navigationBarTitleDisplayMode(.large)
        }
    }
}
