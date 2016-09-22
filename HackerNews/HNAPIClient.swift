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
    
    func getStories(_ type: StoriesType, limit: Int, offset: Int, completion: (_ stories: [Story]?, _ error: NSError?) -> Void) -> Request {
        return Alamofire
            .request(.GET, baseURLString + "/\(type.rawValue)", parameters: ["limit": limit, "offset": offset])
            .validate()
            .responseJSON { (response) -> Void in
                print(response)
                switch response.result {
                case .success(let data):
                    self.responseProcessingQueue.addOperation({ () -> Void in
                        let stories = JSON(data).arrayValue
                            .filter { return $0 != nil } // dirty fix for cleaning out null stories from response. did not go with failable initializer on Story  because there's a bug in the swift compiler that makes it hard to fail initializer on class objects.
                            .map { Story(json: $0) }
                        OperationQueue.main.addOperation({ () -> Void in
                            completion(stories: stories, error: nil)
                        })
                    })
                case .failure(let error):
                    completion(stories: nil, error: error as NSError)
                }
        }
    }
    
    func getStory(_ id: Int, completion: (_ story: Story?, _ error: NSError?) -> Void) -> Request {
        return Alamofire
            .request(.GET, baseURLString + "/items/\(id)")
            .validate()
            .responseJSON { (response) -> Void in
                switch response.result {
                case .success(let data):
                    self.responseProcessingQueue.addOperation({ () -> Void in
                        let story = Story(json: JSON(data))
                        OperationQueue.main.addOperation({ () -> Void in
                            completion(story: story, error: nil)
                        })
                    })
                case .failure(let error):
                    completion(story: nil, error: error as NSError)
                }
        }
    }
    
}
