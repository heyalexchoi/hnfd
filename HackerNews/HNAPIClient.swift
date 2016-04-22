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

class HNAPIClient {
    
    let baseURLString = Private.Constants.HNAPIBaseURLString
    let responseProcessingQueue = NSOperationQueue()
    
    func getStories(type: StoriesType, limit: Int, offset: Int, completion: (stories: [Story]?, error: NSError?) -> Void) -> Request {
        return Alamofire
            .request(.GET, baseURLString + "/\(type.rawValue)", parameters: ["limit": limit, "offset": offset])
            .validate()
            .responseJSON { [weak self] (req, res, result) -> Void in
                switch result {
                case .Success(let data):
                    print("\nreq: \(req)\nres: \(res)\nresult: \(result)\ndata: \(data)")
                    self?.responseProcessingQueue.addOperationWithBlock({ () -> Void in
                        let stories = JSON(data).arrayValue
                            .filter { return $0 != nil } // dirty fix for cleaning out null stories from response. did not go with failable initializer on Story  because there's a bug in the swift compiler that makes it hard to fail initializer on class objects.
                            .map { Story(json: $0) }
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            completion(stories: stories, error: nil)
                        })
                    })
                case .Failure(_, let error):
                    completion(stories: nil, error: error as NSError)
                }
        }
    }
    
    func getStory(id: Int, completion: (story: Story?, error: NSError?) -> Void) -> Request {
        return Alamofire
            .request(.GET, baseURLString + "/items/\(id)")
            .validate()
            .responseJSON { [weak self] (req, res, result) -> Void in
                switch result {
                case .Success(let data):
                    self?.responseProcessingQueue.addOperationWithBlock({ () -> Void in
                        let story = Story(json: JSON(data))
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            completion(story: story, error: nil)
                        })
                    })
                case .Failure(_, let error):
                    completion(story: nil, error: error as NSError)
                }
        }
    }
    
}
