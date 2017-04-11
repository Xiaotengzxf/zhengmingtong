//
//  WebViewController.swift
//  zhenyuntong
//
//  Created by 张晓飞 on 2016/12/24.
//  Copyright © 2016年 zhenyuntong. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController , WKUIDelegate , WKNavigationDelegate {
    
    var linkUrl : String?
    var progressView : UIProgressView!
    var webView : WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: SCREENWIDTH, height: SCREENHEIGHT - 64))
        let request = URLRequest(url: URL(string: linkUrl!)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30)
        webView.load(request)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.sizeToFit()
        self.view.addSubview(webView)
        
        progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: SCREENWIDTH, height: 4))
        progressView.progressTintColor = UIColor.orange
        self.view.addSubview(progressView)
        
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.alpha = 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
            if webView.estimatedProgress >= 1 {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { 
                    [weak self] in
                    self?.progressView.alpha = 0
                }, completion: {[weak self] (finished) in
                    self?.progressView.setProgress(0, animated: false)
                })
            }
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
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
