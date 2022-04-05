//
//  Extension.swift
//  Metiway
//
//  Created by Ravi's mac on 13/06/18.
//  Copyright © 2018 macOs. All rights reserved.
//

import Foundation
import UIKit
import Photos
import AudioToolbox
import Accelerate
import Security

// *************************************************************************
// MARK:-
// MARK:-   Constants
// *************************************************************************


let userDefault = UserDefaults.standard
let appdelegate = UIApplication.shared.delegate as! AppDelegate


func mandatoryMark(_ color: UIColor) -> NSAttributedString {
    
    let mark = " *"
    let attrib = NSAttributedString(string: mark, attributes: [NSAttributedString.Key.font:UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: color])
    return attrib
}

func setAfter(_ delay: Double = 0.01, closure: @escaping @convention(block) () -> Swift.Void) {
    
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}


func takeScreenshot() -> UIImage? {
    var screenshotImage :UIImage?
    let layer = UIApplication.shared.keyWindow!.layer
    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
    guard let context = UIGraphicsGetCurrentContext() else {return nil}
    layer.render(in:context)
    screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return screenshotImage
}

func setCustomdataToUserdefault(_ customData: Any, forKey: String) {
    let data = NSKeyedArchiver.archivedData(withRootObject: customData)
    UserDefaults.standard.set(data, forKey: forKey)
    UserDefaults.standard.synchronize()
}

func getCustomData(_ forKey: String) -> Any? {
    let customData = UserDefaults.standard.object(forKey: forKey) as! Data
    return NSKeyedUnarchiver.unarchiveObject(with: customData)
}


// MARK:-
// MARK:-   Play System Sound
class Sound {
    static var soundID: SystemSoundID = 0
    static func install(_ fileName: String = "", ext: String = "", soundiD: SystemSoundID = 0) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ext) else { return  }
        soundID = soundiD
        AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
    }
    static func play() {
        guard soundID != 0 else { return }
        AudioServicesPlaySystemSound(soundID)
    }
    static func dispose() {
        guard soundID != 0 else { return }
        AudioServicesDisposeSystemSoundID(soundID)
    }
}


// ***************************************************************
// MARK:-
// MARK:-   PHAsset
// ***************************************************************
extension PHAsset {
    
    var originalFilename: String? {
        
        var fname:String?
        
        if #available(iOS 9.0, *) {
            let resources = PHAssetResource.assetResources(for: self)
            if let resource = resources.first {
                fname = resource.originalFilename
            }
        }
        
        if fname == nil {
            fname = self.value(forKey: "filename") as? String
        }
        
        return fname
    }
}


// MARK:-
// MARK:-   UIStoryboard

extension UIStoryboard {
    
    convenience init(_ name:String = "Main") {
        self.init(name: name, bundle: Bundle.main)
    }
    
    class func instantiateVC<T>(_ vc: T.Type, _ name: String = "Main") -> T {
        guard let vctype = UIStoryboard(name).instantiateViewController(withIdentifier: String(describing: vc)) as? T else {
            fatalError(String(describing: vc) + " identifier not found")
        }
        return vctype
    }
}



// ***************************************************************
// MARK:-
// MARK:-  Sequence
// ***************************************************************
extension Sequence where Iterator.Element == UIView {
    
    func setRound() {
        self.forEach { (v) in
            v.setRound()
        }
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        self.forEach { (v) in
            v.cornerRadius = radius
        }
    }
    
    func setRoundBorder(_ width: CGFloat, _ color: String) {
        self.forEach { (v) in
            v.setRoundBorder(width, color)
        }
    }
    
    func setBorder(_ width: CGFloat, _ color: String, _ cornerRadius: CGFloat) {
        self.forEach { (v) in
            v.setBorder(width, color, cornerRadius)
        }
    }
    
    func setShadow(_ radius: CGFloat, _ width: CGFloat, _ height: CGFloat, _ color:String = "686868", _ opacity: Float = 1.0) {
        self.forEach { (v) in
            v.setShadow(radius, width, height, color, opacity)
        }
    }
}

extension Sequence where Iterator.Element == UITextField {
    
    func setCornerRadius(_ radius: CGFloat) {
        self.forEach { (v) in
            v.cornerRadius = radius
        }
    }
    
    func setRoundBorder(_ width: CGFloat, _ color: String) {
        self.forEach { (v) in
            v.setRoundBorder(width, color)
        }
    }
    
    func setBorder(_ width: CGFloat, _ color: String, _ cornerRadius: CGFloat) {
        self.forEach { (v) in
            v.setBorder(width, color, cornerRadius)
        }
    }
    
    func setBlankView(_ width: CGFloat, _ side: Side = .Left) {
        self.forEach { (v) in
            v.setBlankView(width, side)
        }
    }
    
    func setView(_ image: UIImage, _ width: CGFloat, _ imageWidth: CGFloat, _ side: Side = .Left) {
        self.forEach { (v) in
            v.setView(image, width, imageWidth, side)
        }
    }
    
    func setLeftSemantic() {
        self.forEach { (tf) in
            tf.setLeftSemantic()
        }
    }
    
    func setRightSemantic() {
        self.forEach { (tf) in
            tf.setRightSemantic()
        }
    }
}


// MARK:-
// MARK:-   UIWindow
extension UIWindow {
    
    func setRoot<T: UIViewController>(_ vc: T.Type, storyboard: String = "Main") -> Self {
        self.rootViewController = UIStoryboard.instantiateVC(vc, storyboard)
        return self
    }
    
    func setRootVC(_ vc: UIViewController) -> UIWindow {
        self.rootViewController = vc
        return self
    }
}


// ***************************************************************
// MARK:-
// MARK:-  UIViewControler
// ***************************************************************
extension UIViewController {

    func showVC<T : UIViewController>(_ vc: T.Type, storyboard: String = "Main") {
        
        let vcinstance = UIStoryboard.instantiateVC(vc, storyboard)
        if let nav = navigationController {
            nav.show(vcinstance, sender: nil)
        }
        else {
            self.present(vcinstance, animated: true, completion: nil)
        }
    }
    
    func pushVC<T : UIViewController>(_ vc: T.Type, storyboard: String = "Main", animated: Bool = true) {
        
        let vcinstance = UIStoryboard.instantiateVC(vc, storyboard)
        if let nav = navigationController {
            nav.pushViewController(vcinstance, animated: animated)
        }
    }
    
    func backVC() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    


    
    func popToVC<T: UIViewController>(_ viewcontroller: T.Type, animted: Bool = true) {
        if let navvc = navigationController {
            for vc in navvc.viewControllers {
                if vc.isKind(of: viewcontroller) {
                    navvc.popToViewController(vc, animated: animted)
                    break
                }
            }
        }
    }
    
    func getNavVC<T : UIViewController>(_ vc: T.Type, storyboard: String = "Main") -> UINavigationController {
        
        let vc = UIStoryboard.instantiateVC(vc, storyboard)
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        return nav
    }
    
}


// MARK:-
// MARK:-  UIView

extension UIView {
    
    static func getView<T>(viewT: T.Type) -> T {
        
        let v = UINib(nibName: String(describing: viewT), bundle: Bundle.main).instantiate(withOwner: nil, options: nil).first as! T
        return v
    }
    
    static func viewFromNibName(_ name: String) -> UIView? {
        let views = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        return views?.first as? UIView
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    func setRound() {
        self.cornerRadius = self.frame.width/2
    }
    
    func setRoundBorder(_ width: CGFloat, _ color: String) {
        setRound()
        setBorder(width, color)
    }
    
    func setBorder(_ width: CGFloat, _ color: String) {
        self.layer.borderColor = UIColor(color).cgColor
        self.layer.borderWidth = width
    }
    
    func setBorder(_ width: CGFloat, _ color: String, _ cornerRadius: CGFloat) {
        self.layer.borderColor = UIColor(color).cgColor
        self.layer.borderWidth = width
        self.layer.cornerRadius = cornerRadius
    }
    
    func setShadow(_ radius: CGFloat, _ width: CGFloat, _ height: CGFloat, _ color:String = "686868", _ opacity: Float = 1.0) {
        self.layer.shadowColor = UIColor(color).cgColor
        self.layer.shadowOffset = CGSize(width: width, height: height)
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
    func Set_boder_white( _ borderColor: String = "ffffff",_ Corners: UIRectCorner = [.topRight, .bottomLeft])
    {
        let maskPath = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: Corners, cornerRadii: CGSize.init(width: 10.0, height: 10.0))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
        
        let borderLayer = CAShapeLayer.init()
        borderLayer.frame = self.bounds
        borderLayer.path = maskPath.cgPath
        borderLayer.lineWidth = 4
        borderLayer.strokeColor = UIColor(borderColor).cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(borderLayer)
    }
    
    func Set_Corner(_ Corners: UIRectCorner,_ radius: CGFloat, borderLayer name: String? = nil, borderWidth: CGFloat = 0.0, borderColor color: String = "ffffff", backgoundColor: String = "") {
        
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: Corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.frame
        rectShape.position = self.center
        rectShape.path = maskPath
        self.layer.mask = rectShape
        
        if name != nil {
            
            if let layers = self.layer.sublayers {
                for layer1 in layers {
                    if layer1.name == name! {
                        layer1.removeFromSuperlayer()
                    }
                }
            }
            
            let borderLayer = CAShapeLayer.init()
            borderLayer.frame = self.bounds
            borderLayer.path = maskPath
            borderLayer.lineWidth = borderWidth
            borderLayer.strokeColor = UIColor(color).cgColor
            borderLayer.name = name!
            borderLayer.backgroundColor = backgoundColor == "" ? UIColor.clear.cgColor : UIColor(backgoundColor).cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
            self.layer.insertSublayer(borderLayer, at: 0)
        }
    }
    
    
    func setCornersBorders(for corners: UIRectCorner, radii: CGFloat, removeBorderSide: [BorderSide], borderThickness: CGFloat, borderColor: String) {
        
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii)).cgPath
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = frame
        rectShape.position = center
        rectShape.path = maskPath
        layer.mask = rectShape
        
        if let lays = layer.sublayers {
            for lay in lays {
                if lay.name == "all" {
                    lay.removeFromSuperlayer()
                }
            }
        }
        
        let borderlayer1 = CAShapeLayer()
        borderlayer1.path = maskPath
        borderlayer1.fillColor = UIColor.clear.cgColor
        borderlayer1.strokeColor = UIColor(borderColor).cgColor
        borderlayer1.lineWidth = borderThickness
        borderlayer1.name = "all"
        layer.addSublayer(borderlayer1)
        
        if !removeBorderSide.contains(.all) {
            for border in removeBorderSide {
                
                if let lays = layer.sublayers {
                    for lay in lays {
                        if lay.name == String(describing: border) {
                            lay.removeFromSuperlayer()
                        }
                    }
                }
                
                let borderlayer = CAShapeLayer()
                borderlayer.borderColor = backgroundColor!.cgColor
                borderlayer.borderWidth = borderThickness
                borderlayer.name = String(describing: border)
                
                let thick = borderThickness
                
                if border == .top {
                    borderlayer.frame = CGRect(x: thick/2, y: 0, width: frame.width, height: thick)
                }
                if border == .bottom {
                    borderlayer.frame = CGRect(x: thick/2, y: frame.height-thick, width: frame.width-thick, height: thick)
                }
                if border == .left {
                    borderlayer.frame = CGRect(x: 0, y: thick/2, width: thick, height: frame.height-thick)
                }
                if border == .right {
                    borderlayer.frame = CGRect(x: frame.width - thick, y: thick/2, width: thick, height: frame.height-thick)
                }
                layer.addSublayer(borderlayer)
            }
        }
    }
    
    func removeBorderLayer(of borders:[BorderSide]) {
        
        func remove(_ bordersArr:[BorderSide]) {
            for border in bordersArr {
                if let lays = layer.sublayers {
                    for lay in lays {
                        print("&&&&&&")
                        print(lay.name!)
                        print(String(describing: border))
                        if lay.name == String(describing: border) {
                            lay.removeFromSuperlayer()
                        }
                    }
                }
            }
        }
        
        if borders.contains(.all) {
            let names : [BorderSide] = [.left, .right, .top, .bottom, .all]
            remove(names)
        }
        else {
            remove(borders)
        }
    }
    
    
    func setBorder(for borderSide: [BorderSide], borderThickness: [CGFloat], borderColor: [String]) {
        
        if borderSide.count == borderThickness.count && borderSide.count == borderColor.count {
            if !borderSide.contains(.all) {
                for (index,border) in borderSide.enumerated() {
                    
                    if let lays = layer.sublayers {
                        for lay in lays {
                            if lay.name == String(describing: border) {
                                lay.removeFromSuperlayer()
                            }
                        }
                    }
                    
                    let borderlayer = CAShapeLayer()
                    borderlayer.borderColor = UIColor(borderColor[index]).cgColor
                    borderlayer.borderWidth = borderThickness[index]
                    borderlayer.name = String(describing: border)
                    
                    let thick = borderThickness[index]
                    
                    if border == .top {
                        borderlayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: thick)
                    }
                    if border == .bottom {
                        borderlayer.frame = CGRect(x: 0, y: frame.height-thick, width: frame.width, height: thick)
                    }
                    if border == .left {
                        borderlayer.frame = CGRect(x: 0, y: 0, width: thick, height: frame.height)
                    }
                    if border == .right {
                        borderlayer.frame = CGRect(x: frame.width - thick, y: 0, width: thick, height: frame.height)
                    }
                    layer.addSublayer(borderlayer)
                }
            }
            else {
                if let lays = layer.sublayers {
                    for lay in lays {
                        if lay.name == "allborder"{
                            lay.removeFromSuperlayer()
                        }
                    }
                }
                
                let maskPath = UIBezierPath(rect: frame).cgPath
                let borderlayer1 = CAShapeLayer()
                borderlayer1.path = maskPath
                borderlayer1.fillColor = UIColor.clear.cgColor
                borderlayer1.strokeColor = UIColor("").cgColor
                borderlayer1.lineWidth = 0.0
                borderlayer1.name = "allborder"
                layer.addSublayer(borderlayer1)
            }
        }
    }
    
    
    func applyGradient(colours: [UIColor]) -> Void {
        self.applyGradient(colours: colours, locations: nil)
    }
    
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.addSublayer(gradient)
    }
    
    func applyGradient1(colours: [UIColor]) -> Void {
        self.applyGradient1(colours: colours, locations: [0.2,0.5,1.0])
    }
    
    func TextGradient(colours: [UIColor]) -> Void {
        self.applyGradient1(colours: colours, locations: [0.2,0.5,1.0])
    }
    
    func applyGradient1(colours: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = colours.map { $0.cgColor }
        gradient.frame = self.bounds
        gradient.locations = locations
        self.layer.addSublayer(gradient)
    }
    
    var Getwidth : CGFloat {
        get { return self.frame.size.width  }
        set { self.frame.size.width = newValue }
    }
    
    var Getheight : CGFloat {
        get { return self.frame.size.height  }
        set { self.frame.size.height = newValue }
    }
    
    var Getsize:       CGSize  { return self.frame.size}
    
    var Getorigin:     CGPoint { return self.frame.origin }
    var Getx : CGFloat {
        get { return self.frame.origin.x  }
        set { self.frame.origin.x = newValue }
    }
    
    var Gety : CGFloat {
        get { return self.frame.origin.y  }
        set { self.frame.origin.y = newValue }
    }
    
    var Getleft:       CGFloat { return self.frame.origin.x }
    var Getright:      CGFloat { return self.frame.origin.x + self.frame.size.width }
    var Gettop:        CGFloat { return self.frame.origin.y }
    var Getbottom:     CGFloat { return self.frame.origin.y + self.frame.size.height }
    
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            let color = UIColor(cgColor: layer.borderColor!)
            return color
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowOpacity = shadowOpacity
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            return UIColor(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue!.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowOpacity = shadowOpacity
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowColor = shadowColor?.cgColor
            layer.shadowOffset = newValue
            layer.shadowOpacity = shadowOpacity
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowColor = shadowColor?.cgColor
            layer.shadowOffset = shadowOffset
            layer.shadowOpacity = newValue
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable
    var enableMaskBound: Bool {
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = enableMaskBound
        }
    }
    
}

extension UIScreen {
    
    class var height : CGFloat {
        get { return UIScreen.main.bounds.height }
    }
    
    class var Width : CGFloat {
        get { return UIScreen.main.bounds.width }
    }
}



// MARK:-
// MARK:-  UIColor

extension UIColor {
    convenience init(_ hex:String, _ alpha:CGFloat = 1.0) {
        let hex = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner            = Scanner(string: hex as String)
        
        if (hex.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        
        var color:UInt32 = 0
        scanner.scanHexInt32(&color)
        
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}



//MARK:-
//MARK:-   String

extension String {
    
    var attributed : NSAttributedString {
        return NSAttributedString(string: self)
    }
    
    var trimed: String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    var isEmptyOrWhiteSpace : Bool {
        return self.isEmpty && (self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty)
    }

    var validateEmail : Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.trimed)
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func toDate(_ dateFormat: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = dateFormat
        return df.date(from: self)
    }
    
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}


extension NSAttributedString {
    
    static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
    {
        let result = NSMutableAttributedString()
        result.append(left)
        result.append(right)
        return result
    }
}


//MARK:-
//MARK:-   Dateformatter

extension DateFormatter {
    
    func getMMMDateStringFrom(_ date: Date) -> String {
        
        let df = DateFormatter()
        df.dateFormat = "dd-MMM-yyyy"
        return df.string(from: date)
    }
    
    class func getTime(_ forDate: NSDate) -> String {
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "h:mm a"
        return dformatter.string(from: forDate as Date)
    }
    
    class func getDate(_ forDate: String) -> Date {
        
        let dformatter = DateFormatter()
        dformatter.dateStyle = .medium
        return dformatter.date(from: forDate)!
    }
    
    class func relativeTo(_ date: Date) -> String {
        
        let dformatter = DateFormatter()
        dformatter.dateStyle = .medium
        dformatter.doesRelativeDateFormatting = true
        return dformatter.string(from: date)
    }
}

//MARK:-
//MARK:-    UIResponder
extension UIResponder {
    
    func firstAvailableViewController() -> UIViewController? {
        return self.traverseResponderChainForFirstViewController()
    }
    
    func firstAvailableTableView() -> UITableView? {
        return self.traverseResponderChainForFirstTableView()
    }
    
    func traverseResponderChainForFirstViewController() -> UIViewController? {
        if let nextResponder = self.next {
            if nextResponder is UIViewController {
                return nextResponder as? UIViewController
            } else if nextResponder is UIView {
                return nextResponder.traverseResponderChainForFirstViewController()
            } else {
                return nil
            }
        }
        return nil
    }
    
    func traverseResponderChainForFirstTableView() -> UITableView? {
        if let nextResponder = self.next {
            if nextResponder is UITableView {
                return nextResponder as? UITableView
            } else if nextResponder is UIView {
                return nextResponder.traverseResponderChainForFirstTableView()
            } else {
                return nil
            }
        }
        return nil
    }
}


// MARK:-
// MARK:-  UITableView
extension UITableView {
    
    var setContentInset : (CGFloat?,CGFloat?,CGFloat?,CGFloat?) {
        set {
            let inset = contentInset
            contentInset = UIEdgeInsets(top: newValue.0 ?? inset.top, left: newValue.1 ?? inset.left, bottom: newValue.2 ?? inset.bottom, right: newValue.3 ?? inset.right)
        }
        get {
            return (contentInset.top, contentInset.left, contentInset.bottom, contentInset.right)
        }
    }
    
    func dequeCell<T>(_ cell: T.Type, indexPath: IndexPath) -> T {
        let cell1 = dequeueReusableCell(withIdentifier: String(describing: cell), for: indexPath) as! T
        return cell1
    }
}


//MARK:-
//MARK:-   UITextField
enum Side {
    case Left
    case Right
}

public enum BorderSide {
    case top
    case bottom
    case left
    case right
    case all
}



//MARK:-
//MARK:-   UITextField

extension UITextField {
    
    func setBlankView(_ width: CGFloat, _ side: Side = .Left) {
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: width))
        
        if side == .Left {
            self.leftView = paddingView
            self.leftViewMode = .always
        }
        else if side == .Right {
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    }
    
    func setView(_ image: UIImage, _ width: CGFloat, _ imageWidth: CGFloat, _ side: Side = .Left) {
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: self.Getheight))
        let imgview = UIImageView(frame: CGRect(x: 0, y: 0, width: imageWidth, height: imageWidth))
        imgview.image = image
        imgview.center = paddingView.center
        paddingView.addSubview(imgview)
        
        let tapOnImgview = UITapGestureRecognizer(target: self, action: #selector(tapOnImgView(_:)))
        tapOnImgview.numberOfTapsRequired = 1
        paddingView.addGestureRecognizer(tapOnImgview)
        
        if side == .Left {
            self.leftView = paddingView
            self.leftViewMode = .always
        }
        else if side == .Right {
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    }
    @objc func tapOnImgView(_ recognizer: UITapGestureRecognizer) {
        self.becomeFirstResponder()
    }
    
    public func setRightSemantic() {
        self.semanticContentAttribute = .forceRightToLeft
        self.textAlignment = .right
    }
    
    func setLeftSemantic() {
        self.semanticContentAttribute = .forceLeftToRight
        self.textAlignment = .left
    }
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}


//MARK:-
//MARK:-   UILable
extension UILabel {
    
    var getLableHeight: CGFloat {
        let height = text!.height(withConstrainedWidth: Getwidth, font: font)
        return height
    }
    
    func applyLineSpace(_ space: CGFloat) {
        
        let attribStr = NSMutableAttributedString(string: self.text!)
        let paragStyle = NSMutableParagraphStyle()
        paragStyle.lineSpacing = space
        paragStyle.alignment = self.textAlignment
        attribStr.addAttributes([NSAttributedString.Key.paragraphStyle: paragStyle], range: NSMakeRange(0, attribStr.length))
        self.attributedText = attribStr
    }
    
}


// MARK:-
// MARK:-  Circle View
class CircleView : UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRound()
    }
}


class CircleImageView : UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRound()
    }
}

class CircleButton : UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRound()
    }
}


// MARK:-
// MARK:-  UIImageView
extension UIImageView {
    
}

extension UIButton {
    
}


// MARK:-
// MARK:-  UIImage
extension UIImage {
    
    /// Represents a scaling mode
    enum ScalingMode {
        case aspectFill
        case aspectFit
        
        /// Calculates the aspect ratio between two sizes
        ///
        /// - parameters:
        ///     - size:      the first size used to calculate the ratio
        ///     - otherSize: the second size used to calculate the ratio
        ///
        /// - return: the aspect ratio between the two sizes
        func aspectRatio(between size: CGSize, and otherSize: CGSize) -> CGFloat {
            let aspectWidth  = size.width/otherSize.width
            let aspectHeight = size.height/otherSize.height
            
            switch self {
            case .aspectFill:
                return max(aspectWidth, aspectHeight)
            case .aspectFit:
                return min(aspectWidth, aspectHeight)
            }
        }
    }
    
    /// Scales an image to fit within a bounds with a size governed by the passed size. Also keeps the aspect ratio.
    ///
    /// - parameter:
    ///     - newSize:     the size of the bounds the image must fit within.
    ///     - scalingMode: the desired scaling mode
    ///
    /// - returns: a new scaled image.
    func scaled(to newSize: CGSize, scalingMode: UIImage.ScalingMode = .aspectFill) -> UIImage {
        
        let aspectRatio = scalingMode.aspectRatio(between: newSize, and: size)
        
        /* Build the rectangle representing the area to be drawn */
        var scaledImageRect = CGRect.zero
        
        scaledImageRect.size.width  = size.width * aspectRatio
        scaledImageRect.size.height = size.height * aspectRatio
        scaledImageRect.origin.x    = (newSize.width - size.width * aspectRatio) / 2.0
        scaledImageRect.origin.y    = 0
        
        /* Draw and retrieve the scaled image */
        UIGraphicsBeginImageContext(scaledImageRect.size)
        
        draw(in: scaledImageRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    public func tintWithColor(_ color: UIColor) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
            //UIGraphicsBeginImageContext(self.size)
            let context = UIGraphicsGetCurrentContext()
            // flip the image
            context?.scaleBy(x: 1.0, y: -1.0)
            context?.translateBy(x: 0.0, y: -self.size.height)
            // multiply blend mode
            context?.setBlendMode(.multiply)
            let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            context?.clip(to: rect, mask: self.cgImage!)
            color.setFill()
            context?.fill(rect)
            // create uiimage
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
        }
}

extension CGFloat {
    
    var dp: CGFloat {
        return (self / 320) * UIScreen.main.bounds.width
    }
}


