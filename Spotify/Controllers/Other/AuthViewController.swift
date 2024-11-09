//
//  AuthViewController.swift
//  Spotify
//
//  Created by Aleyna Işıkdağlılar on 1.11.2024.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKNavigationDelegate {
    
    private let webView: WKWebView = {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences = prefs
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()
    
    public var completionHandler: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sign In"
        view.backgroundColor = .systemBackground
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        guard let url = AuthManager.shared.signInURL else {
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }
    
    //    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    //        guard let url = webView.url else {
    //            return
    //        }
    //        print("2")
    ////        Exchange the code for access token
    //        guard let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: {
    //
    //            $0.name == "code"
    //
    //        })?.value else {
    //            print("5")
    //            return
    //        }
    //
    //        print("Code")
    //        print(code)
    //    }
   
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url {
//            print("Navigating to URL: \(url.absoluteString)")
            
            // Kod parametresini içeren URL kontrolü
            if url.absoluteString.starts(with: "spotify-ios-quick-start://spotify-login-callback") {
                if let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value {
//                    print("Code: \(code)")
                    webView.isHidden = true
                    AuthManager.shared.exchangeCodeForToken(code: code) { [weak self] success in
                        DispatchQueue.main.async {
                            self?.navigationController?.popToRootViewController(animated: true)
                            self?.completionHandler?(success)
                        }
                    }
                    // Kodla ilgili işlemleri burada gerçekleştirin
                } else {
                    print("Kod parametresi yok.")
                }
            }
        }
        
        decisionHandler(.allow) // Navigasyona izin ver
    }
}
