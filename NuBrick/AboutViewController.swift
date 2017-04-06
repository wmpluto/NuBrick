//
//  AboutViewController.swift
//  NuBrick
//  关于界面
//  Created by mwang on 03/02/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit


class AboutViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url = Bundle.main.url(forResource: "About", withExtension: "html")
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
        webView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Use webview to show the About.html
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.url
        if url?.scheme == "http" || url?.scheme == "https" {
            return !UIApplication.shared.openURL(url!)
        }
        return true
    }
}
