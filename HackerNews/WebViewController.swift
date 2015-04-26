//
//  WebViewController.swift
//  HackerNews
//
//  Created by Alex Choi on 4/26/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import WebKit
import SnapKit

class WebViewController: UIViewController {
    
    let webView = WKWebView()
    let URL: NSURL
    
    init(url: NSURL) {
        URL = url
        webView.loadRequest(NSURLRequest(URL: url))
        super.init(nibName: nil, bundle: nil)
        webView.navigationDelegate = self
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = webView.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: "dismissButtonDidPress")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "actionButtonDidPress")
        
        view.addSubview(webView)
        webView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(view)
        }
    }
    
    func dismissButtonDidPress() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func actionButtonDidPress() {
        presentViewController(UIActivityViewController(activityItems: [URL], applicationActivities: nil), animated: true, completion: nil)
    }

}

extension WebViewController: WKNavigationDelegate {
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        title = webView.title
    }
    
}