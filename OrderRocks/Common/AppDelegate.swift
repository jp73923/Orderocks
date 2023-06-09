//
//  AppDelegate.swift
//  OrderRocks
//
//  Created by user on 01/02/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var isFromProductUpdate = false
    var isProductId = ""
    var window: UIWindow?
    var AppColor = UIColor.init(red: 30.0/255.0, green:93.0/255.0, blue:146.0/255.0, alpha:1.0)
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point fort customization after application launch.
        
        UINavigationBar.appearance().barTintColor = AppColor
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
        
        UIApplication.shared.statusBarUIView?.backgroundColor = UIColor.white

        //Push setup
        self.registerForRemoteNotification()

        return true
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        UserDefaults.standard.setValue(nil, forKey: "SaveOrderURL")
        UserDefaults.standard.synchronize()
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CheckAppNewVersion"), object: nil)
        UserDefaults.standard.setValue(nil, forKey: "SaveOrderURL")
        UserDefaults.standard.synchronize()
    }
}


//MARK: Remote notifications
extension AppDelegate: UNUserNotificationCenterDelegate{
    func registerForRemoteNotification() {
        let center  = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options:[.alert, .sound]){ (granted, error) in }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    //MARK:- Get Device Token
    func application(_ application: UIApplication, didRegister notificationSettings: UNNotificationSettings) {
        if application.isRegisteredForRemoteNotifications == true{
            application.registerForRemoteNotifications()
        } else {
            print("application.isRegisteredForRemoteNotifications() ====== \(application.isRegisteredForRemoteNotifications)")
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        NSLog("Device Token : %@", deviceTokenString)
     //   UserDefaultManager.setStringToUserDefaults(value: deviceTokenString, key: UD_PushToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error, terminator: "")
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if #available(iOS 14.0, *) {
            completionHandler([.sound, .banner])
        } else {
            // Fallback on earlier versions
        }
    }
    
    //Called when a notification is delivered to a background app
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}

extension UIApplication {
var statusBarUIView: UIView? {

    if #available(iOS 13.0, *) {
        let tag = 3848245

        let keyWindow = UIApplication.shared.connectedScenes
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows.first

        if let statusBar = keyWindow?.viewWithTag(tag) {
            return statusBar
        } else {
            let height = keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
            let statusBarView = UIView(frame: height)
            statusBarView.tag = tag
            statusBarView.layer.zPosition = 999999

            keyWindow?.addSubview(statusBarView)
            return statusBarView
        }

    } else {

        if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        }
    }
    return nil
  }
}
