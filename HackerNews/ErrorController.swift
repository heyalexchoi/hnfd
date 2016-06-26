//
//  ErrorController.swift
//  HackerNews
//
//  Created by Alex Choi on 8/14/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import TSMessages

class ErrorController {
    
    class func showErrorNotification(error: NSError?) {
        
        guard let error = error else { return }
        
        if error.code == NSURLErrorCancelled {
            return
        }
        if let rootNavigationController = UIApplication.sharedApplication().delegate?.window??.rootViewController {
            
            var title = error.localizedDescription
            
            if let userInfo = error.userInfo as? [String: AnyObject],
                let messages = userInfo[Error.messagesKey] as? String {
                title = messages
            }
            
            TSMessage.showNotificationInViewController(rootNavigationController, title: title, subtitle:nil , image: nil, type: .Error, duration: 2, callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .NavBarOverlay, canBeDismissedByUser: true)
        }
    }
    
    class func showErrorNotification(error: Error?) {
        guard let error = error else { return }
        showErrorNotification(error.error)
    }    
}
