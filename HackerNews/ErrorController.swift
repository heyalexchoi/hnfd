//
//  ErrorController.swift
//  HackerNews
//
//  Created by Alex Choi on 8/14/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import TSMessages

class ErrorController {
    
    class func showErrorNotification(_ message: String?) {
        
        guard let message = message else { return }
        guard let rootNavigationController = UIApplication.shared.delegate?.window??.rootViewController else { return }
        
        TSMessage.showNotification(in: rootNavigationController, title: message, subtitle:nil , image: nil, type: .error, duration: 2, callback: nil, buttonTitle: nil, buttonCallback: nil, at: .navBarOverlay, canBeDismissedByUser: true)
    }
    
    class func showErrorNotification(_ error: NSError?) {
        
        guard let error = error else { return }
        
        if error.code == NSURLErrorCancelled {
            return
        }
        
        var title = error.localizedDescription
        
        if let userInfo = error.userInfo as? [String: AnyObject],
            let messages = userInfo[HNFDError.messagesKey] as? String {
            title = messages
        }
        
        showErrorNotification(title)
    }
    
    class func showErrorNotification(_ error: HNFDError?) {
        guard let error = error else { return }
        showErrorNotification(error.error)
    }
    
    class func showErrorNotification(_ error: Error?) {
        guard let error = error else { return }
        debugPrint("show error notification with error type: \(error)")
        showErrorNotification(error as NSError)
    }
}
