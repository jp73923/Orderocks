//
//  codeUrlVC.swift
//  Metiway
//
//  Created by Mayank on 22/05/21.
//  Copyright © 2021 Mayank. All rights reserved.
//


import Foundation
import UIKit
import WebKit
import SVProgressHUD

class codeUrlVC: UIViewController {
    
    //***********************************************
    //MARK:-
    //MARK:-   Outlets
    //***********************************************
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var btnBack: UIButton!
    
    //***********************************************
    //MARK:-
    //MARK:-   Other Properties
    //***********************************************
    
    var link = ""
    

    
    //***********************************************
    //MARK:-
    //MARK:-  VC Life Cycle
    //***********************************************
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        webView.scrollView.bounces = false
        webView.scrollView.bouncesZoom = false
        webView.scrollView.alwaysBounceVertical = false
        webView.scrollView.alwaysBounceHorizontal = false
        
        btnBack.setImage(UIImage(named: "Back")?.tintWithColor(UIColor.black), for: .normal)
        
        urlOpen(link)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        SVProgressHUD.dismiss()
    }
    
    func urlOpen(_ linkTxt : String) {
        
        if let url = URL(string: linkTxt) {
           print(url)
           webView.load(URLRequest(url: url))
           SVProgressHUD.show()
        }
    }
}

//***********************************************
//MARK:-
//MARK:-   IBActions
//***********************************************
extension codeUrlVC {

    @IBAction func menuAction(_ sender: UIButton) {
        
      //navigationController?.popToVC(HomeViewController.self)
        if "https://stage.orderocks.com/barcodescannerback".contains("barcodescannerback") {
            self.navigationController?.popViewController(animated: true)
        }
        //popToVC(HomeViewController.self)
    }
}


//***********************************************
//MARK:-
//MARK:-   WKNavigationDelegate
//***********************************************
extension codeUrlVC: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        SVProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        SVProgressHUD.dismiss()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
               UIApplication.shared.canOpenURL(url) {
                
                let url_str = url.absoluteString
                
                decisionHandler(.allow)
                
                print(url_str)
                
                guard let urlAsString = navigationAction.request.url?.absoluteString.lowercased() else {
                    
                    print(navigationAction.request.url?.absoluteString.lowercased() as Any)
                    return
                }
                
                if urlAsString.range(of: "the url that the button redirects the webpage to") != nil {
                    // do something
                }
                
                if urlAsString == "https://stage.orderocks.com/login" {
                    showVC(UserBarcodeScannerVC.self)
                }
                
                if urlAsString.contains("barcodescannerback") {
                    self.navigationController?.popViewController(animated: true)
                }
                
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
}





