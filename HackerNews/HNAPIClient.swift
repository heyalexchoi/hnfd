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

enum StoriesType: String {
    case
    Top = "topstories",
    New = "newstories",
    Show = "showstories",
    Ask = "askstories",
    Job = "jobstories",
    Saved = "savedstories"
    static var allValues = [Top, New, Show, Ask, Job, Saved]
    var title: String {
        return rawValue.stringByReplacingOccurrencesOfString("stories", withString: " stories").capitalizedString
    }
}

class HNAPIClient {
    
    let baseURLString = Constants.HNAPIBaseURLString
    let responseProcessingQueue = NSOperationQueue()
    
    func getStories(type: StoriesType, limit: Int, offset: Int, completion: (stories: [Story]?, error: NSError?) -> Void) -> Request {
        return Alamofire
            .request(.GET, baseURLString + "/\(type.rawValue)", parameters: ["limit": limit, "offset": offset])
            .validate()
            .responseJSON { [weak self] (_, _, json, error) -> Void in
                if let error = error {
                    completion(stories: nil, error: error)
                } else if let json: AnyObject = json {
                    self?.responseProcessingQueue.addOperationWithBlock({ () -> Void in
                        let stories = JSON(json).arrayValue.map { Story(json: $0) }
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            completion(stories: stories, error: nil)
                        })
                    })
                }
        }
    }
    
    func getStory(id: Int, completion: (story: Story?, error: NSError?) -> Void) -> Request {
        return Alamofire
            .request(.GET, baseURLString + "/items/\(id)")
            .validate()
            .responseJSON { [weak self] (_, _, json, error) -> Void in
                if let error = error {
                    completion(story: nil, error: error)
                } else if let json: AnyObject = json {
                    self?.responseProcessingQueue.addOperationWithBlock({ () -> Void in
                        let story = Story(json: JSON(json))
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            completion(story: story, error: nil)
                        })
                    })
                }
        }
    }
    
}
