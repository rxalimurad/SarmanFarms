//
//  ViewController.swift
//  SarmanFarms
//
//  Created by Ali Murad on 26/06/2023.
//


import UIKit
import SystemConfiguration
import WebKit
import JGProgressHUD

class ViewController: UIViewController, WKNavigationDelegate , WKUIDelegate{
    @IBOutlet private var webKit: WKWebView!
    @IBOutlet private var image: UIImageView!
    @IBOutlet private var act: UIActivityIndicatorView!
    @IBOutlet private var topConst: NSLayoutConstraint!
    
    @IBOutlet weak var autoLogin: UIButton!
    
    
    let url = "https://www.sarmanfarms.com/app/";
    var internetReachabilityTimer: Timer?
    let hud = JGProgressHUD()

    var isInterON = true
    
    var backButton: UIBarButtonItem?
    var logoutButton: UIBarButtonItem?
    
    func hideBarButtonItem() {
        backButton?.isEnabled = false
        backButton?.tintColor = .clear
       }
    
    func showBarButtonItem() {
        backButton?.isEnabled = true
        backButton?.tintColor = .black
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image.isHidden {
            autoLogin.isHidden = !(UserDefaults.standard.isBiomaticOn  && !UserDefaults.standard.userName.isEmpty && !UserDefaults.standard.password.isEmpty && webKit.url == URL(string: self.url))
        } else {
            autoLogin.isHidden = true
        }
    }
    override func viewDidLoad() {
        autoLogin.isHidden = true
        super.viewDidLoad()
        hud.textLabel.text = "Loading"
        webKit.scrollView.bounces = false
        webKit.navigationDelegate = self
        webKit.isHidden = true
        webKit.allowsLinkPreview = false
        
        internetReachabilityTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(checkInternetConnectivity), userInfo: nil, repeats: true)
        webKit.uiDelegate = self

        // Disable zooming by setting the viewport meta tag
        let script = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webKit.configuration.userContentController.addUserScript(userScript)
        
        
        topConst.constant = topConst.constant - (navigationController?.navigationBar.frame.height ?? 0)
        
        backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.backward"), style: .plain, target: self, action: #selector(backButtonPressed))
//        logoutButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.left"), style: .plain, target: self, action: #selector(backButtonPressed))
        
        
        
        hideBarButtonItem()
        navigationItem.leftBarButtonItem = backButton
//        navigationItem.rightBarButtonItem = logoutButton
        webKit.load(URLRequest(url: URL(string: url)!))
    }
    @objc func backButtonPressed() {
        if webKit.canGoBack {
            webKit.goBack()
        }
    }
    
    @IBAction func autologinaction(_ sender: Any) {
        self.setCredentialsInWebView(username: UserDefaults.standard.userName, password: UserDefaults.standard.password)
    }
    @objc func checkInternetConnectivity() {
            let isInternetReachable = isInternetAvailable()
            if isInternetReachable {
                webKit.isHidden = false
                image.isHidden = true
                act.isHidden = true
                if !isInterON {
                    isInterON = true
                    DispatchQueue.main.async {
                        self.webKit.load(URLRequest(url: URL(string: self.url)!))
                    }
                }
            } else {
                webKit.isHidden = true
                image.isHidden = false
                act.isHidden = false
                isInterON = false
            }
        }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        .allow
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        hud.show(in: self.view)
        if let pageTitle = webView.title {
            self.navigationController?.title = "Home"
            self.navigationItem.title = pageTitle
        } else {
            self.navigationController?.title = "Home"
            self.navigationItem.title = "Mobile Airtime NG"
        }

    }
    
    func setCredentialsInWebView(username: String, password: String) {
        let script = """
        document.getElementById('username').value = '\(username)';
        document.getElementById('password').value = '\(password)';
        document.querySelector('form.user').submit();
        """

        webKit.evaluateJavaScript(script, completionHandler: nil)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hud.dismiss()
        
            autoLogin.isHidden = !(UserDefaults.standard.isBiomaticOn  && !UserDefaults.standard.userName.isEmpty && !UserDefaults.standard.password.isEmpty && webView.url == URL(string: self.url))
                
        webView.evaluateJavaScript("document.title") { (result, error) in
            if let title = result as? String {
                self.navigationController?.title = "Home"
                self.navigationItem.title = title
            } else {
                self.navigationController?.title = "Home"
                self.navigationItem.title = "Mobile Airtime NG"
            }
        }
        
        
        if webKit.canGoBack {
            showBarButtonItem()
        } else {
            hideBarButtonItem()
        }
        
        webKit.isHidden = false
        image.isHidden = true
        act.isHidden = true
    }
    
    func isInternetAvailable() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        return (isReachable && !needsConnection)
    }
    // Disable long press gesture
    private func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKContextMenuElementInfo) -> Bool {
            return false
        }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            }))
            completionHandler()
            present(alertController, animated: true, completion: nil)
        }

        
    
}

