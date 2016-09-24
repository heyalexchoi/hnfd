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
    
    func getParsedArticleForURL(_ articleURL: Foundation.URL, completion: @escaping (_ article: ReadabilityArticle?, _ error: HNFDError?) -> Void) -> DataRequest {
        
        let readabilityURLString = baseURLString + "/content/v1/parser"
        let articleURLString = articleURL.absoluteString.removingPercentEncoding ?? articleURL.absoluteString
        let parameters: [String: Any] = ["url": articleURLString, "token": Private.Keys.readabilityParserAPIToken]
        let encoding = URLEncoding.default
        
        let request = Alamofire.request(readabilityURLString, method: .get, parameters: parameters, encoding: encoding, headers: nil)
        
        return request
            .validate()
            .responseJSON { [weak self] (response) -> Void in
                switch response.result {
                case .success(let json):
                    self?.responseProcessingQueue.addOperation({ () -> Void in
                        let article = ReadabilityArticle(json: JSON(json))
                        OperationQueue.main.addOperation({ () -> Void in
                            completion(article, nil)
                        })
                    })
                case .failure(let error):
                    completion(nil, error as? HNFDError)
                }
        }
    }
}
