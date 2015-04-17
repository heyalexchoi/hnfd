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



class HNAPIClient {
    
    let baseURLString = "https://hacker-news.firebaseio.com"
    static let sharedClient = HNAPIClient()
    
    func getTopStories(completion: (storyItems: [StoryItem]?, error: NSError?) -> Void) -> Request {
        return Alamofire
            .request(.GET, baseURLString + "/v0/topstories.json")
            .responseJSON { (_, _, json, error) -> Void in
                if let error = error {
                    completion(storyItems: nil, error: error)
                } else if let json: AnyObject = json {
                    let storyItems = JSON(json).arrayValue.map { StoryItem(json: $0) }
                    completion(storyItems: storyItems, error: nil)
                }
        }
    }
    
    func getStory(id: Int, completion: (story: Story?, error: NSError?) -> Void) -> Request {
        return Alamofire
            .request(.GET, baseURLString + "/v0/item/\(id).json")
            .responseJSON { (_, _, json, error) -> Void in
                if let error = error {
                    completion(story: nil, error: error)
                } else if let json: AnyObject = json {
                    completion(story: Story(json: JSON(json)), error: nil)
                }
        }
    }
}
