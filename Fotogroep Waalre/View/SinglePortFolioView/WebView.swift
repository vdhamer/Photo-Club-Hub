//
//  WebView.swift
//  Fotogroep Waalre
//
//  Created by Peter van den Hamer on 03/01/2022.
//

import WebKit

struct WebView {

    // inputs
    let webView: WKWebView

    init () {
        // use WKNavigationDelegate to block unwanted navigation:
        //  https://www.hackingwithswift.com/articles/112/the-ultimate-guide-to-wkwebview

        let configuration = WKWebViewConfiguration() // not really used to configure here
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.customUserAgent = "Fotogroep Waalre app"
    }

}
