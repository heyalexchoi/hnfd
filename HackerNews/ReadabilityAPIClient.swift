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
    let responseProcessingQueue = OperationQueue()
    
    func getParsedArticleForURL(_ URL: Foundation.URL, completion: (_ article: ReadabilityArticle?, _ error: NSError?) -> Void) -> Request {
        let URLString = URL.absoluteString.stringByRemovingPercentEncoding ?? URL.absoluteString
        return Alamofire
            .request(.GET,
                baseURLString + "/content/v1/parser",
                parameters: ["url": URLString, "token": Private.Keys.readabilityParserAPIToken])
            .validate()
            .responseJSON { [weak self] (response) -> Void in
                switch response.result {
                case .success(let json):
                    self?.responseProcessingQueue.addOperation({ () -> Void in
                        let article = ReadabilityArticle(json: JSON(json))
                        OperationQueue.main.addOperation({ () -> Void in
                            completion(article: article, error: nil)
                        })
                    })
                case .failure(let error):
                    completion(article: nil, error: error as NSError)                    
                }
        }
    }
}
