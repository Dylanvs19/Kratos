//
//  TermsController.swift
//  Kratos
//
//  Created by Dylan Straughan on 9/28/17.
//  Copyright © 2017 Kratos, Inc. All rights reserved.
//

import Foundation
import WebKit

class TermsController: UIViewController , WKNavigationDelegate, CurtainPresenter, AnalyticsEnabled {
    var webView = WKWebView()
    var curtain: Curtain = Curtain()
    
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
        self.addCurtain()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log(event: .privacyPolicy)
    }
    
    //MARK:- WKNavigationDelegate
    
    private func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error.localizedDescription)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.curtain.loadStatus.value = .loading
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.curtain.loadStatus.value = .none
    }
}
