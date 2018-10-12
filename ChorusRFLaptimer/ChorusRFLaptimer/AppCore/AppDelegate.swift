//
//  AppDelegate.swift
//  ChorusRFLaptimer
//
//  Created by Lazar Djordjevic on 9/14/17.
//  Copyright © 2017 Lazar Djordjevic. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var orientationLock = UIInterfaceOrientationMask.all
    var window: UIWindow?
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }
    
    struct AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
        
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldShowToolbarPlaceholder = false
        
        setupDefaultValues()
        
        FirebaseApp.configure()
        //Fabric.sharedSDK().debug = true

        return true
    }
    
    func setupDefaultValues()
    {
        UserDefaults.standard.register(defaults: [UserDefaultsId.timeToPrepareForRace : 5])
        UserDefaults.standard.register(defaults: [UserDefaultsId.lapsToGo : 3])
        UserDefaults.standard.register(defaults: [UserDefaultsId.speakMessages : true])
        UserDefaults.standard.register(defaults: [UserDefaultsId.speakLapTimes : true])
        UserDefaults.standard.register(defaults: [UserDefaultsId.voltageAdjustment : 0])
        UserDefaults.standard.register(defaults: [UserDefaultsId.voltageMonitorOn : false])
        UserDefaults.standard.register(defaults: [UserDefaultsId.isBTMode : true])
        UserDefaults.standard.register(defaults: [UserDefaultsId.phoneSleep : true])
    }
    
    func applicationWillResignActive(_ application: UIApplication) {    }

    func applicationDidEnterBackground(_ application: UIApplication) {    }

    func applicationWillEnterForeground(_ application: UIApplication) {    }

    func applicationDidBecomeActive(_ application: UIApplication) {    }

    func applicationWillTerminate(_ application: UIApplication) {    }
}
