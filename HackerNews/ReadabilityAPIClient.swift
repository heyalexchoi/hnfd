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
            .responseJSON { [weak self] (req, res, result) -> Void in
                switch result {
                case .Success(let json):
                    self?.responseProcessingQueue.addOperationWithBlock({ () -> Void in
                        let article = ReadabilityArticle(json: JSON(json))
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            completion(article: article, error: nil)
                        })
                    })
                case .Failure(let data, let error):
                    if let data = data,
                        messages = JSON(data: data)["messages"].string {
                            let messagedError = NSError(domain: Public.Constants.hackerNewsErrorDomain, code: 1, userInfo: [NSUnderlyingErrorKey: error as NSError, Public.Constants.errorMessagesKey: messages])
                            completion(article: nil, error: messagedError)
                    } else {
                        completion(article: nil, error: error as NSError)
                    }                    
                }
        }
    }
}