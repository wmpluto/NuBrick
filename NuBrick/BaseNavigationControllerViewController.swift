//
//  BaseNavigationControllerViewController.swift
//  NuBrick
//  Navigation 默认设置
//  Created by mwang on 15/12/2016.
//  Copyright © 2016 nuvoton. All rights reserved.
//

import UIKit


class BaseNavigationControllerViewController: UINavigationController {

    // Not used now
    override func viewDidLoad() {
        super.viewDidLoad()

        let layer = self.navigationBar.layer
        self.navigationBar.barTintColor = nuvotonRedColor
        self.navigationBar.tintColor = UIColor.white
        layer.cornerRadius = 3.0
        layer.shadowOffset = CGSize(width: 1.0, height: 2.0)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 3.0
        navigationBar.tintColor = UIColor.white
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
