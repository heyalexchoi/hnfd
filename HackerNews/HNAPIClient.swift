//
//  HNAPIClient.swift
//  HackerNews
//
//  Created by alexchoi on 4/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let errorDomain = "HNFD Error Domain"

struct HNAPIClient {
    
    let baseURLString = Private.Constants.HNAPIBaseURLString
    let responseProcessingQueue = OperationQueue()
    
    func getStory(_ id: Int, completion: @escaping (_ story: Story?, _ error: HNFDError?) -> Void) -> Request {
        return Alamofire
            .request("\(baseURLString)/items/\(id)", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .validate()
            .responseJSON { (response) -> Void in
                switch response.result {
                case .success(let data):
                    self.responseProcessingQueue.addOperation({ () -> Void in
                        let story = Story(json: JSON(data))
                        OperationQueue.main.addOperation({ () -> Void in
                            completion(story, nil)
                        })
                    })
                case .failure(let error):
                    completion(nil, error as? HNFDError)
                }
        }
    }
    
}
