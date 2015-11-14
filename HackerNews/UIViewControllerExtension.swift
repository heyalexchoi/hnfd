//
//  UIViewControllerExtension.swift
//  HackerNews
//
//  Created by Alex Choi on 11/14/15.
//  Copyright © 2015 Alex Choi. All rights reserved.
//

import Foundation

extension UIViewController {
    
    func presentWebViewController(URL: NSURL, animated: Bool = true, completion: (() -> Void)? = nil) {
        presentViewController(WebViewController(URL: URL), animated: animated, completion: completion)
    }
    
}