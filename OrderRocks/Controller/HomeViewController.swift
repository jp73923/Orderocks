//
//  HomeViewController.swift
//  OrderRocks
//
//  Created by user on 01/02/2021.
//

import UIKit
import WebKit

class HomeViewController: UIViewController {
    
    @IBOutlet var spinnerView: UIActivityIndicatorView!
    
    var webUrl = ""
    
    var back = UIBarButtonItem()
    var webViewCookieStore: WKHTTPCookieStore!
    
    @IBOutlet weak var printBtn: UIButton!
    @IBOutlet weak var btnScanBarcode: UIButton!
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var splashVew: UIView!
    
    var AppColor = UIColor.init(red: 30.0/255.0, green:93.0/255.0, blue:146.0/255.0, alpha:1.0)
    var boolIsFromScanBarcodeProductOpen:Bool = false
    var strOpenProductURLFromBarcodeScan:String = ""
    var counter:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webUrl = Constants.baseURL // Assign Base Url
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore =  WKWebsiteDataStore.nonPersistent()
        configuration.preferences = preferences
        
        webViewCookieStore = webView.configuration.websiteDataStore.httpCookieStore
        print(webViewCookieStore as Any)
        printBtn.isHidden = true
        
        //Set the webView Frame
        webView.navigationDelegate = self // set Delegate of WebView
        webView.uiDelegate = self
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.allowsLinkPreview = true
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsBackForwardNavigationGestures = true
        
        perform(#selector(hideSplash), with: nil, afterDelay: 1.0)
        
        UserDefaults.standard.setValue(false, forKey: "Open_CheckOrder_Page")
        UserDefaults.standard.synchronize()

        self.navigationItem.hidesBackButton = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let product_link = UserDefaults.standard.value(forKey: "Cart_Open") as? String {
            if let url = URL(string: product_link) {
                webView.load(URLRequest(url: url))
                UserDefaults.standard.set(nil, forKey: "Cart_Open")
            }
        } else{
            if let openCheckOrderPage = UserDefaults.standard.value(forKey: "Open_CheckOrder_Page") as? Bool {
                //Open order detail page
                if let orderUrl = UserDefaults.standard.value(forKey: "SaveOrderURL") as? String,orderUrl.count > 0 {
                    if let url = URL(string: orderUrl) as? URL{
                        webView.load(URLRequest(url: url))
                    }
                } else {
                    if openCheckOrderPage {
                        if let orderId = UserDefaults.standard.value(forKey: "OrderId") as? String {
                            let url = URL(string: webUrl + "Admin/Order/OrderValidation?OrderId=" + orderId)!
                            webView.load(URLRequest(url: url))
                        } else {
                            let url = URL(string: webUrl + "Admin/Order/OrderValidation")!
                            webView.load(URLRequest(url: url))
                        }
                    } else {
                        let url = URL(string: webUrl)!
                        webView.load(URLRequest(url: url))
                    }
                }
            } else {
                let url = URL(string: webUrl)!
                webView.load(URLRequest(url: url))
            }
        }
    }
    
    @objc func backTapped() -> Void{
        if(webView.canGoBack) {
            webView.goBack()
        }
    }
    
    //Hide splash view
    @objc func hideSplash() {
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "Orderocks"
        self.navigationController?.navigationBar.isHidden = true
        self.splashVew.isHidden = true
        webView.bringSubviewToFront(self.view)
    }
    
    func downloadFile(url_Str: String){
        let url = url_Str
        
        let Array = url.components(separatedBy: "/")
        var str = Array[Array.count - 1]
        
        str = str.replacingOccurrences(of: "?", with: "")
        str = str.replacingOccurrences(of: "=", with: "")

        let fileName = str
        
        savePdf(urlString: url, fileName: fileName)
        
    }
    
    func savePdf(urlString:String, fileName:String) {
        DispatchQueue.main.async {
            let url = URL(string: urlString)
            let pdfData = try? Data.init(contentsOf: url!)
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let pdfNameFromUrl = "\(fileName).pdf"
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            do {
                try pdfData?.write(to: actualPath, options: .atomic)
                print("pdf successfully saved!")
                
                let alert = UIAlertController(title: "Alert", message: "PDF successfully saved!", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
                
            } catch {
                print("Pdf could not be saved")
            }
        }
    }
    
    @IBAction func printBtnClicked(_ sender: Any) {
        
        self.printDoc()
        
    }
    
    @IBAction func btnScanBarcode(_ sender: Any) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
            self.showVC(UserBarcodeScannerVC.self)
        }
    }
  
    
    func printDoc() -> Void {
        
        let printInfo: UIPrintInfo = UIPrintInfo.printInfo()
        printInfo.outputType = .general
        printInfo.jobName = (self.webView.url?.absoluteString)!
        print(self.webView.url?.absoluteString ?? "hvhg hbjh  j")
        printInfo.duplex = .none
        printInfo.orientation = .portrait
        
        let printController = UIPrintInteractionController.shared
        printController.printPageRenderer = nil
        printController.printingItems = nil
        printController.printingItem = webView.url!
        
        printController.printInfo = printInfo
        printController.showsNumberOfCopies = true
        
        printController.present(animated: true, completionHandler: nil)
    }
}

extension HomeViewController: WKNavigationDelegate, WKUIDelegate{
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        print(webView.url)
        spinnerView.isHidden = false
        spinnerView.startAnimating()
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        if(webView.canGoBack) {
            
            back.tintColor = .white
            
        } else {
            back.tintColor = AppColor
        }
        
        spinnerView.isHidden = true
        spinnerView.stopAnimating()
        
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        spinnerView.isHidden = true
        spinnerView.stopAnimating()
    }
    
    func webView(webView: WKWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if request.url?.absoluteString == "iosapp://click" {
            // what do you want to do.
         }
         // or you can do as like this.
        if request.url?.scheme == "iosapp" {
             if request.url?.host == "click" {
                // what do you want to do.
             }
             return false
         }
        
         return true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let cookieScript = "document.cookie;"
           webView.evaluateJavaScript(cookieScript) { (response, error) in
            if let response = response {
                    print(response as! String)
            }
        }
        
        if navigationAction.navigationType == .formSubmitted {
            if let url = navigationAction.request.url,
               UIApplication.shared.canOpenURL(url) {
                let url_str = url.absoluteString
                if url_str.contains("OrderValidation") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                            UserDefaults.standard.setValue(false, forKey: "Open_CheckOrder_Page")
                            UserDefaults.standard.synchronize()
                            UserDefaults.standard.setValue(nil, forKey: "SaveOrderURL")
                            UserDefaults.standard.synchronize()
                            if let orderId = url_str.components(separatedBy: "=")[1] as? String {
                                UserDefaults.standard.setValue(orderId, forKey: "OrderId")
                                UserDefaults.standard.synchronize()
                            }
                            self.showVC(CheckProductExistScannerVC.self)
                        }
                    }
                }
            }
        }
        if navigationAction.navigationType == .linkActivated  {
            if let url = navigationAction.request.url,
               UIApplication.shared.canOpenURL(url) {
                //https://stage.orderocks.com/Admin/Product/ScanBarcode
                let url_str = url.absoluteString
                
                if url_str.contains("PdfInvoice") {
                    
                    //printDoc()
                    downloadFile(url_Str: url_str)
                    decisionHandler(.cancel)
                }
                
                if url_str.contains("apple.com") || url_str.contains("play.google.com") {
                    UIApplication.shared.open(url)
                    decisionHandler(.allow)
                    
                }else{
                    if url_str.contains("Product/ScanBarcode") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                              //  UserDefaults.standard.setValue(false, forKey: "Open_CheckOrder_Page")
                              //  UserDefaults.standard.synchronize()
                                self.showVC(ScanProductVC.self)
                                decisionHandler(.allow)
                            }
                        }
                    } else if url_str.contains("barcodescanner") {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                            let url = URL(string: self.webUrl)!
                            webView.load(URLRequest(url: url))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                                self.showVC(UserBarcodeScannerVC.self)
                                decisionHandler(.allow)
                            }
                        }
                    }else if url_str.contains("OrderProductScanWithBarcode") { //For check product exist in order
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                                UserDefaults.standard.setValue(false, forKey: "Open_CheckOrder_Page")
                                UserDefaults.standard.synchronize()
                                self.showVC(CheckProductExistScannerVC.self)
                                decisionHandler(.allow)
                            }
                        }
                    }else if url_str.contains("OrderValidationScanOrderNumber") { // For scan order id and fetch
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                                UserDefaults.standard.setValue(false, forKey: "Open_CheckOrder_Page")
                                UserDefaults.standard.synchronize()
                                self.showVC(GetOrderIdUsingScanVC.self)
                                decisionHandler(.allow)
                            }
                        }
                    }else {
                        
                        decisionHandler(.allow)
                        
                        guard let urlAsString = navigationAction.request.url?.absoluteString.lowercased() else {
                            
                            print(navigationAction.request.url?.absoluteString.lowercased() as Any)
                            return
                        }
                    }
                }
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
        
    }
}

extension HomeViewController {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {

        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completionHandler()
        }))

        self.present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {

        var alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)

        if (UIDevice.current.userInterfaceIdiom == .pad) {
            alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        }
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completionHandler(true)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))

        self.present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {

        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)

        alertController.addTextField { (textField) in
            textField.text = defaultText
        }

        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }

        }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in

            completionHandler(nil)

        }))

        self.present(alertController, animated: true, completion: nil)

    }
}


extension WKWebViewConfiguration {
    /// Async Factory method to acquire WKWebViewConfigurations packaged with system cookies
    static func cookiesIncluded(completion: @escaping (WKWebViewConfiguration?) -> Void) {
        let config = WKWebViewConfiguration()
        guard let cookies = HTTPCookieStorage.shared.cookies else {
            completion(config)
            return
        }
        let dataStore = WKWebsiteDataStore.nonPersistent()
        let waitGroup = DispatchGroup()
        for cookie in cookies {
            waitGroup.enter()
            dataStore.httpCookieStore.setCookie(cookie) { waitGroup.leave() }
        }
        waitGroup.notify(queue: DispatchQueue.main) {
            config.websiteDataStore = dataStore
            completion(config)
        }
    }
}

