//
//  ErrorController.swift
//  HackerNews
//
//  Created by Alex Choi on 8/14/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import TSMessages

class ErrorController {
    
    class func showErrorNotification(_ error: NSError?) {
        
        guard let error = error else { return }
        
        if error.code == NSURLErrorCancelled {
            return
        }
        if let rootNavigationController = UIApplication.shared.delegate?.window??.rootViewController {
            
            var title = error.localizedDescription
            
            if let userInfo = error.userInfo as? [String: AnyObject],
                let messages = userInfo[HNFDError.messagesKey] as? String {
                title = messages
            }
            
            TSMessage.showNotification(in: rootNavigationController, title: title, subtitle:nil , image: nil, type: .error, duration: 2, callback: nil, buttonTitle: nil, buttonCallback: nil, at: .navBarOverlay, canBeDismissedByUser: true)
        }
    }
    
    class func showErrorNotification(_ error: HNFDError?) {
        guard let error = error else { return }
        showErrorNotification(error.error)
    }    
}
