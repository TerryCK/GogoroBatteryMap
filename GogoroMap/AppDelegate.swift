//
//  AppDelegate.swift
//  GogoroMap
//
//  Created by 陳 冠禎 on 2017/8/9.
//  Copyright © 2017年 陳 冠禎. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Firebase
import SwiftyStoreKit
import AlamofireNetworkActivityLogger

extension UIApplication {
    
    static var mapViewController: MapViewController? {
        ((shared.delegate as? AppDelegate)?.window?.rootViewController as? UINavigationController)?.viewControllers.first { $0.isKind(of: MapViewController.self) } as? MapViewController
    }
}



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    
    private var autoUpdate = TimePeriod(effectiveDuration: 60*60)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        DataManager.shared.fetchStations {
            Answers.logCustomEvent(withName: "didFinishLaunchingWithOptions ", customAttributes: ["didFinishLaunchingWithOptions" : "fetchStations"])
        }
        
        window?.rootViewController = UINavigationController(rootViewController: MapViewController())
        window?.makeKeyAndVisible()
        setupIAPOberserver()
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [kGADSimulatorID, Keys.standard.gadiPhone] as? [String]
        switch Environment.environment {
        case .release:
            FirebaseApp.configure()
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            Fabric.sharedSDK().debug = true
            Fabric.with([Crashlytics.self])
        case .debug:
            NetworkActivityLogger.shared.startLogging()
            NetworkActivityLogger.shared.level = .debug
        }
        print("\n==== enviroment: \(Environment.environment) ====\n")
        
        return true
    }
    
    private func setupIAPOberserver() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases where [.purchased, .restored].contains(purchase.transaction.transactionState) && purchase.needsFinishTransaction {
                SwiftyStoreKit.finishTransaction(purchase.transaction)
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        DataManager.shared.save()
        
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        if autoUpdate.isExpired {
            DataManager.shared.fetchStations {
                self.autoUpdate.reset()
                Answers.logCustomEvent(withName: "AutoUpdate", customAttributes: ["AutoUpdate" : "fetchStations"])
            }
        }
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        DataManager.shared.save()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        
    }
}

