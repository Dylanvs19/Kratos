//
//  TermsController.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/28/17.
//  Copyright © 2017 Dylan Straughan. All rights reserved.
//

import Foundation
import WebKit

class TermsController: UIViewController , WKNavigationDelegate {
    var webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // init and load request in webview.
        webView = WKWebView(frame: self.view.frame)
        webView.navigationDelegate = self
        guard let url = URL(string: "https://getkratos.com/privacy/") else { return }
        let request = URLRequest(url: url)
        webView.load(request)
        self.view.addSubview(webView)
        self.view.sendSubview(toBack: webView)
    }
    
    //MARK:- WKNavigationDelegate
    
    private func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
    }
}
