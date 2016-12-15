//
//  Util.swift
//  NuBrick
//
//  Created by mwang on 15/12/2016.
//  Copyright © 2016 nuvoton. All rights reserved.
//

import UIKit
import MapKit


let nuvotonRedColor = UIColor(red: 218.0/255.0, green: 0, blue: 36.0/255.0, alpha: 1.0)

// NOTIFICATIONS
let HexiwearDidSignOut = "HexiwearDidSignOut"

// TopMostViewController extensions
extension UIViewController {
    func topMostViewController() -> UIViewController {
        // Handling Modal views
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.topMostViewController()
        }
        
        // Handling UIViewController's added as subviews to some other views.
        for view in self.view.subviews
        {
            // Key property which most of us are unaware of / rarely use.
            if let subViewController = view.next {
                if subViewController is UIViewController {
                    let viewController = subViewController as! UIViewController
                    return viewController.topMostViewController()
                }
            }
        }
        return self
    }
}

extension UITabBarController {
    override func topMostViewController() -> UIViewController {
        return self.selectedViewController!.topMostViewController()
    }
}

extension UINavigationController {
    override func topMostViewController() -> UIViewController {
        return self.visibleViewController!.topMostViewController()
    }
}



// Global misc functions

func isValidEmailAddress(email: String) -> Bool {
    let regExPattern = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
    do {
        let regEx = try NSRegularExpression(pattern: regExPattern, options: .caseInsensitive)
        let regExMatches = regEx.numberOfMatches(in: email, options: [], range: NSMakeRange(0, email.characters.count))
        return regExMatches == 0 ? false : true
    }
    catch {
        return false
    }
}

func getPrivateDocumentsDirectory() -> String? {
    
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    if paths.count == 0 { print("No private directory"); return nil }
    var documentsDirectory = paths[0]
    documentsDirectory = (documentsDirectory as NSString).appendingPathComponent("Private Documents")
    if let _ = try? FileManager.default.createDirectory(atPath: documentsDirectory, withIntermediateDirectories: true, attributes: nil) {
        return documentsDirectory
    }
    return nil
}
