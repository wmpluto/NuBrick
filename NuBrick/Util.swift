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
let applicationTitle = "NuBrick"

let EnableCamera = "EnableCamera"
let EnableTorch = "EnableTorch"
let EnableMusic = "EnableMusic"
let CameraOn = "CameraOn"
let MusicOn = "MusicOn"
let TorchOn = "TorchOn"
let NoRespondTime = 30

func showSimpleAlertWithTitle(title: String!, message: String, viewController: UIViewController, OKhandler: ((UIAlertAction?) -> Void)? = nil) {
    DispatchQueue.main.async() {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: OKhandler)
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}

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
