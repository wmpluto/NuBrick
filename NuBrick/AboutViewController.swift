//
//  AboutViewController.swift
//  NuBrick
//
//  Created by mwang on 03/02/2017.
//  Copyright © 2017 nuvoton. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        /*
         NSString* path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
         NSURL* url = [NSURL fileURLWithPath:path];
         NSURLRequest* request = [NSURLRequest requestWithURL:url] ;
         [webView loadRequest:request];
         */
        let url = Bundle.main.url(forResource: "About", withExtension: "html")
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
        webView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.url
        if url?.scheme == "http" || url?.scheme == "https" {
            return !UIApplication.shared.openURL(url!)
        }
        return true
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
