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
        let URLString = URL.absoluteString.stringByRemovingPercentEncoding ?? URL.absoluteString
        return Alamofire
            .request(.GET,
                baseURLString + "/content/v1/parser",
                parameters: ["url": URLString, "token": Private.Keys.readabilityParserAPIToken])
            .validate()
            .responseJSON { [weak self] (response) -> Void in
                switch response.result {
                case .Success(let json):
                    self?.responseProcessingQueue.addOperationWithBlock({ () -> Void in
                        let article = ReadabilityArticle(json: JSON(json))
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            completion(article: article, error: nil)
                        })
                    })
                case .Failure(let error):
                    completion(article: nil, error: error as NSError)                    
                }
        }
    }
}