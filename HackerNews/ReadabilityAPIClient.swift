//
//  ReadabilityAPIClient.swift
//  HackerNews
//
//  Created by Alex Choi on 4/17/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import Alamofire
import SwiftyJSON

class ReadabilityAPIClient {
    
    let baseURLString = "https://readability.com/api"
    let responseProcessingQueue = NSOperationQueue()
    
    func getParsedArticleForURL(URL: NSURL, completion: (article: ReadabilityArticle?, error: NSError?) -> Void) -> Request {
        return Alamofire
            .request(.GET,
                baseURLString + "/content/v1/parser",
                parameters: ["url": URL, "token": Private.Keys.readabilityParserAPIToken])
            .validate()
            .responseJSON { [weak self] (req, res, json, error) -> Void in
                if let error = error {
                    // grab error message if there is one, and return new error with that message in user info
                    if let errorJSON: AnyObject = json,
                        let messages: String = JSON(errorJSON)["messages"].string {
                        let errorWithMessage = NSError(domain: Public.Constants.hackerNewsErrorDomain, code: 1, userInfo: [NSUnderlyingErrorKey: error, Public.Constants.errorMessagesKey: messages])
                        completion(article: nil, error: errorWithMessage)
                        return
                    }

                    completion(article: nil, error: error)
                } else if let json: AnyObject = json {
                    self?.responseProcessingQueue.addOperationWithBlock({ () -> Void in
                        let article = ReadabilityArticle(json: JSON(json))
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            completion(article: article, error: nil)
                        })
                    })
                }
        }
    }
    
}


