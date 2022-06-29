//
//  GetOrderIdUsingScanVC.swift
//  OrderRocks
//
//  Created by Jay on 30/03/22.
//

import UIKit
import AVFoundation
import Alamofire
import WebKit
class GetOrderIdUsingScanVC: UIViewController,AVCaptureMetadataOutputObjectsDelegate {
    
    //***********************************************
    //MARK:-
    //MARK:-   Outlets
    //***********************************************
    
    
    @IBOutlet weak var sacnerView: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var bntInfo: UIImageView!
    @IBOutlet weak var btnFlash: UIImageView!
    
    
    //***********************************************
    //MARK:-
    //MARK:-   Other Properties
    //***********************************************
    
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    var captureDevice:AVCaptureDevice?

    var lastCapturedCode:String?
    let ScannerInfoPopView = UIView.getView(viewT: ScannerInfoPopVIews.self)
    let RetryScanViews = UIView.getView(viewT: RetryScanView.self)
    
    public var barcodeScanned:((String) -> ())?
    
    private var allowedTypes = [AVMetadataObject.ObjectType.upce,
                                AVMetadataObject.ObjectType.code39,
                                AVMetadataObject.ObjectType.code39Mod43,
                                AVMetadataObject.ObjectType.ean13,
                                AVMetadataObject.ObjectType.ean8,
                                AVMetadataObject.ObjectType.code93,
                                AVMetadataObject.ObjectType.code128,
                                AVMetadataObject.ObjectType.pdf417,
                                AVMetadataObject.ObjectType.aztec,
                                AVMetadataObject.ObjectType.interleaved2of5,
                                AVMetadataObject.ObjectType.itf14,
                                AVMetadataObject.ObjectType.dataMatrix,
                                AVMetadataObject.ObjectType.qr]
    
    
    //***********************************************
    //MARK:-
    //MARK:-  VC Life Cycle
    //***********************************************
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(InfoimageTapped(gesture:)))
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(FlashTapbtn(gesture:)))
        // add it to the image view;
        bntInfo.addGestureRecognizer(tapGesture)
        btnFlash.addGestureRecognizer(tapGesture1)
        // make sure imageView can be interacted with by user
        bntInfo.isUserInteractionEnabled = true
        btnFlash.isUserInteractionEnabled = true
        
        //For Test My side
       /* let strURL = "https://stage.orderocks.com/Admin/Order/OrderValidation?OrderId=55"
        
        UserDefaults.standard.setValue(strURL, forKey: "SaveOrderURL")
        UserDefaults.standard.synchronize()
        backVC()*/
    }
    override func viewWillAppear(_ animated: Bool) {
            if #available(iOS 11, *) {
                let dataStore = WKWebsiteDataStore.default()
                dataStore.httpCookieStore.getAllCookies({ (cookies) in
                    print(cookies)
                    for i in cookies{
                        let dict = i
                        if dict.name == ".Nop.Customer"{
                            Resultvalue = dict.value
                        }
                    }
                })
            } else {
                guard let cookies = HTTPCookieStorage.shared.cookies else {
                    return
                }
                print(cookies)
            }
            
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaults.standard.setValue("", forKey: "OrderId")
        UserDefaults.standard.synchronize()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Retrieve the default capturing device for using the camera
        if let audiocap = AVCaptureDevice.default(for: AVMediaType.video) as? AVCaptureDevice{
            self.captureDevice = audiocap
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            var error:NSError?
            let input: AnyObject!
            do {
                input = try AVCaptureDeviceInput(device:audiocap)
                //            self.captureDevice?.torchMode = .on
            } catch let error1 as NSError {
                error = error1
                input = nil
            }
            
            if (error != nil) {
                return
            }
            
            // Initialize the captureSession object and set the input device on the capture session.
            captureSession = AVCaptureSession()
            captureSession!.addInput(input as! AVCaptureInput)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession!.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = self.allowedTypes
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = sacnerView.layer.bounds
            sacnerView.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession?.startRunning()
            
            // Move the message label to the top view
            // view.bringSubview(toFront: messageLabel)
            
            // Initialize QR Code Frame to highlight the QR code

            qrCodeFrameView?.layer.borderColor = UIColor.red.cgColor
            qrCodeFrameView?.layer.borderWidth = 2
            qrCodeFrameView?.autoresizingMask = [UIView.AutoresizingMask.flexibleTopMargin, UIView.AutoresizingMask.flexibleBottomMargin, UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleRightMargin]
        }
        
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoPreviewLayer?.frame = self.sacnerView.layer.bounds
        
        let orientation = UIApplication.shared.statusBarOrientation
        
        switch(orientation) {
        case UIInterfaceOrientation.landscapeLeft:
            videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeLeft
            
        case UIInterfaceOrientation.landscapeRight:
            videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.landscapeRight
            
        case UIInterfaceOrientation.portrait:
            videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
            
        case UIInterfaceOrientation.portraitUpsideDown:
            videoPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portraitUpsideDown
            
        default:
            print("Unknown orientation state")
        }
    }
    
    public override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        videoPreviewLayer?.frame = sacnerView.layer.bounds
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects == nil || metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            // messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if self.allowedTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            
            qrCodeFrameView?.frame = barCodeObject.bounds;
            
            
            if metadataObj.stringValue != nil {
                
                //messageLabel.text = metadataObj.stringValue
                lastCapturedCode = metadataObj.stringValue
                
                var qrScanValue = String(lastCapturedCode!)
                print(qrScanValue)
                
                qrScanValue = qrScanValue.replacingOccurrences(of: "*", with: "")
                qrScanValue = qrScanValue.replacingOccurrences(of: " ", with: "")

               /* let strURL = Constants.baseURL + "Admin/Order/OrderValidation?OrderId=" + qrScanValue
                
                UserDefaults.standard.setValue(strURL, forKey: "SaveOrderURL")
                UserDefaults.standard.synchronize()
                backVC()*/
                
                self.checkValidOrderId(orderID: qrScanValue)
                
                self.captureSession?.stopRunning()
            }
        }
    }
    
    func checkValidOrderId(orderID:String) {
        let result = Constants.baseURL + "order/orderexists?orderid=" + orderID
        
        var request = URLRequest(url: URL(string: result)!,timeoutInterval: Double.infinity)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                
                return
            }
            let resultApi = (String(data: data, encoding: .utf8)!)
            let result = self.convertToDictionary(text: resultApi)
            let bool = result!["success"] as? Bool ?? false
            
            if bool{
                //let links = Constants.baseURL + "product/ProductDetails?code=" + strCode
                
                DispatchQueue.main.sync {
                    let strURL = Constants.baseURL + "Admin/Order/OrderValidation?OrderId=" + orderID

                    UserDefaults.standard.setValue(strURL, forKey: "SaveOrderURL")
                    UserDefaults.standard.synchronize()
                    self.backVC()
                   /* UserDefaults.standard.set(links, forKey: "Product_Open")
                    UserDefaults.standard.synchronize()
                    self.navigationController?.popViewController(animated: true)*/
                }
                
            }else{
                DispatchQueue.main.sync {
                        let alert = UIAlertController(title: nil, message: "Order id not valid!", preferredStyle: UIAlertController.Style.alert)
                        if #available(iOS 13.0, *) {
                            alert.overrideUserInterfaceStyle = UIUserInterfaceStyle.dark
                        } else {
                            // Fallback on earlier versions
                        }
                        self.present(alert, animated: true, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.dismiss(animated: true)
                           // self.captureSession?.startRunning()
                        }
                    
                   /* let appdelegate = UIApplication.shared.delegate as! AppDelegate

                    //(appdelegate.window!.rootViewController! as! UINavigationController).viewControllers.last!.view.addSubview(self.RetryScanViews)
                    self.view.addSubview(self.RetryScanViews)
                    self.RetryScanViews.frame = UIScreen.main.bounds
                    self.RetryScanViews.PopUpView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
                    self.RetryScanViews.btnOpenCamera.addTarget(self, action: #selector(self.Opencamera(_:)), for: .touchUpInside)
                    UIView.animate(withDuration: 0.25)
                    {
                        self.RetryScanViews.PopUpView.transform = CGAffineTransform.identity
                    }*/
                }
            }
        }
        task.resume()
    }
    
    //***********************************************
    //MARK:-
    //MARK:-   Method
    //***********************************************
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    @objc func InfoimageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
            (appdelegate.window!.rootViewController! as! UINavigationController).viewControllers.last!.view.addSubview(ScannerInfoPopView)
            ScannerInfoPopView.frame = UIScreen.main.bounds
            ScannerInfoPopView.popUpView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
            ScannerInfoPopView.btnCancle.addTarget(self, action: #selector(self.Close(_:)), for: .touchUpInside)
            
            UIView.animate(withDuration: 0.25)
            {
                self.ScannerInfoPopView.popUpView.transform = CGAffineTransform.identity
           }
        }
    }
    
    @objc func FlashTapbtn(gesture: UIGestureRecognizer) {
        
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                device.torchMode = AVCaptureDevice.TorchMode.off
                btnFlash.image = UIImage(named: "flash_off")
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                    btnFlash.image = UIImage(named: "flash_on")
                } catch {
                    print(error)
                }
            }
            
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    
    @objc func Close(_ sender: UIButton)
    {
        UIView.animate(withDuration: 0.25, animations: {
            self.ScannerInfoPopView.popUpView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }) { (done) in
            self.ScannerInfoPopView.removeFromSuperview()
        }
    }
    
    @objc func Opencamera(_ sender:UIButton) {
        
        UIView.animate(withDuration: 0.25, animations: {
            self.RetryScanViews.PopUpView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }) { (done) in
            self.RetryScanViews.removeFromSuperview()
        }
        // Retrieve the default capturing device for using the camera
        self.captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        var error:NSError?
        let input: AnyObject!
        do {
            input = try AVCaptureDeviceInput(device:captureDevice!)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if (error != nil) {
            return
        }
        
        // Initialize the captureSession object and set the input device on the capture session.
        captureSession = AVCaptureSession()
        captureSession!.addInput(input as! AVCaptureInput)
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession!.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = self.allowedTypes
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = sacnerView.layer.bounds
        sacnerView.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession?.startRunning()
        
        // Move the message label to the top view
        // view.bringSubview(toFront: messageLabel)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        qrCodeFrameView?.layer.borderColor = UIColor.red.cgColor
        qrCodeFrameView?.layer.borderWidth = 2
        qrCodeFrameView?.autoresizingMask = [UIView.AutoresizingMask.flexibleTopMargin, UIView.AutoresizingMask.flexibleBottomMargin, UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleRightMargin]
        
        sacnerView.addSubview(qrCodeFrameView!)
        sacnerView.bringSubviewToFront(qrCodeFrameView!)
    }
}


//***********************************************
//MARK:-
//MARK:-   IBActions
//***********************************************

extension GetOrderIdUsingScanVC {
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        UserDefaults.standard.setValue(true, forKey: "Open_CheckOrder_Page")
        UserDefaults.standard.synchronize()
        backVC()
    }
}

