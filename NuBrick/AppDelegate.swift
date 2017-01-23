//
//  AppDelegate.swift
//  NuBrick
//
//  Created by mwang on 13/12/2016.
//  Copyright © 2016 nuvoton. All rights reserved.
//

import UIKit
import Foundation
import Photos
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.setAppUserDefault(name: "DefaultPreferences", type: "plist")
        self.Authorize()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func setAppUserDefault(name: String, type: String) {
        let defaultPrefsFile = Bundle.main.url(forResource: name, withExtension: type)
        let defaultPrefs = NSDictionary(contentsOf: defaultPrefsFile!)
        UserDefaults.standard.register(defaults: defaultPrefs as! [String : Any])
        UserDefaults.standard.set(false, forKey: CameraOn)
        UserDefaults.standard.set(false, forKey: TorchOn)
        UserDefaults.standard.set(false, forKey: MusicOn)
        UserDefaults.standard.synchronize()
    }
    
    func Authorize() {
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: nil)
            break
        default:
            break
        }
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({_ in })
            break
        default:
            break
        }
    }

}

