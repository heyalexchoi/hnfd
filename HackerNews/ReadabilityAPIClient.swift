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
                parameters: ["url": URL, "token": PrivateKeys.readabilityParserAPIToken])
            .responseJSON { [weak self] (_, _, json, error) -> Void in
                if let error = error {
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


