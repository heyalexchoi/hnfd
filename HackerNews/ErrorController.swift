//
//  ErrorController.swift
//  HackerNews
//
//  Created by Alex Choi on 8/14/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import TSMessages

class ErrorController {
    
    class func showErrorNotification(error: NSError) {
        if error.code == NSURLErrorCancelled {
            return
        }
        if let rootNavigationController = UIApplication.sharedApplication().delegate?.window??.rootViewController {
            
            var title = error.localizedDescription
            
            if let userInfo = error.userInfo as? [String: AnyObject],
                let messages = userInfo[Public.Constants.errorMessagesKey] as? String {
                title = messages
            }
            
            TSMessage.showNotificationInViewController(rootNavigationController, title: title, subtitle:nil , image: nil, type: .Error, duration: 2, callback: nil, buttonTitle: nil, buttonCallback: nil, atPosition: .NavBarOverlay, canBeDismissedByUser: true)
        }
    }
    
}
