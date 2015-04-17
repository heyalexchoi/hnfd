//
//  WebViewController.swift
//  HackerNews
//
//  Created by alexchoi on 4/17/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//


class ArticleViewController: UIViewController {

    let webView = UIWebView()
    let articleURL: NSURL
    
    init(articleURL: NSURL) {
        self.articleURL = articleURL
        super.init(nibName: nil, bundle: nil)
        
        for view in [webView] {
            view.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.view.addSubview(view)
        }
        
        view.twt_addConstraintsWithVisualFormatStrings([
            "H:|[webView]|",
            "V:|[webView]|"], views: [
            "webView": webView])
        
        let request = NSURLRequest(URL: articleURL, cachePolicy: .ReturnCacheDataElseLoad, timeoutInterval: 3)
        webView.loadRequest(request)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
