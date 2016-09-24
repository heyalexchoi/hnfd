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
    
    func presentWebViewController(_ URL: Foundation.URL, animated: Bool = true, completion: (() -> Void)? = nil) {
        let webViewController = WebViewController(url: URL)
        webViewController.delegate = self
        present(webViewController, animated: animated, completion: completion)
    }
    
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}
