//
//  AppDelegate.swift
//  OrderRocks
//
//  Created by user on 01/02/2021.
//

import UIKit
import OneSignal

@main
class AppDelegate: UIResponder, UIApplicationDelegate , OSSubscriptionObserver {
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges) {
        
        
        if !stateChanges.from.isSubscribed && stateChanges.to.isSubscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(stateChanges)")
        
        if let playerId = stateChanges.to.pushToken {
            print("Current playerId \(playerId)")
            UserDefaults.standard.setValue(playerId, forKey:"device_token")
            UserDefaults.standard.synchronize()
        }
        
        
    }
    
    
    
    var window: UIWindow?

    var AppColor = UIColor.init(red: 30.0/255.0, green:93.0/255.0, blue:146.0/255.0, alpha:1.0)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UINavigationBar.appearance().barTintColor = AppColor
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().isTranslucent = false
        
        registerOneSignalNotification(launchOptions: launchOptions)
        
        UIApplication.shared.statusBarUIView?.backgroundColor = UIColor.white
        //30, 93, 146
        return true
    }
    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        UserDefaults.standard.setValue(nil, forKey: "SaveOrderURL")
        UserDefaults.standard.synchronize()
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        UserDefaults.standard.setValue(nil, forKey: "SaveOrderURL")
        UserDefaults.standard.synchronize()
    }
    //MARK: OneSignal Settings
    func registerOneSignalNotification(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Void {
        
        let notifWillShowInForegroundHandler: OSNotificationWillShowInForegroundBlock = { notification, completion in
            print("Received Notification: ", notification.notificationId ?? "no id")
            print("launchURL: ", notification.launchURL ?? "no launch url")
            print("content_available = \(notification.contentAvailable)")
            if let additionalData = notification.additionalData {
                print("additionalData: ", additionalData)
                
                if let actionSelected = notification.actionButtons {
                    print("actionSelected: ", actionSelected)
                }
            }
        }
        
        let notificationOpenedBlock: OSNotificationOpenedBlock = { result in
            // This block gets called when the user reacts to a notification received
            let notification: OSNotification = result.notification
            
            print("Message: ", notification.body ?? "empty body")
            print("badge number: ", notification.badge)
            print("notification sound: ", notification.sound ?? "No sound")
            print(notification)
            if let additionalData = notification.additionalData {
                print("additionalData: ", additionalData)
                
                if let actionSelected = notification.actionButtons {
                    print("actionSelected: ", actionSelected)
                }
            }
        }
        
        
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("333a983c-3e90-4e61-acd1-4089d977d255")
        
        OneSignal.setNotificationOpenedHandler(notificationOpenedBlock)
        OneSignal.setNotificationWillShowInForegroundHandler(notifWillShowInForegroundHandler)

        
        
        OneSignal.promptLocation()
        OneSignal.add(self as OSSubscriptionObserver)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
          print("User accepted notifications: \(accepted)")
        })
        
    }
    //MARK: Ends OneSignal Settings
    
    
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
