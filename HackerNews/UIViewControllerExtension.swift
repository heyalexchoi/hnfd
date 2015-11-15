//
//  UIViewControllerExtension.swift
//  HackerNews
//
//  Created by Alex Choi on 11/14/15.
//  Copyright © 2015 Alex Choi. All rights reserved.
//

import Foundation
import SafariServices

extension UIViewController: SFSafariViewControllerDelegate {
    
    func presentWebViewController(URL: NSURL, animated: Bool = true, completion: (() -> Void)? = nil) {
        let webViewController = WebViewController(URL: URL)
        webViewController.delegate = self
        presentViewController(webViewController, animated: animated, completion: completion)
    }
    
    public func safariViewControllerDidFinish(controller: SFSafariViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}