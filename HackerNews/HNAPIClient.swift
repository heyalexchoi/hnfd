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
import Dollar


class HNAPIClient {
    
    static let sharedClient = HNAPIClient()
    let baseURLString = "https://hacker-news.firebaseio.com"
    
    func getTopStories(completion: (ids: [Int]?, error: NSError?) -> Void) -> Request {
        return Alamofire
            .request(.GET, baseURLString + "/v0/topstories.json")
            .responseJSON { (_, _, json, error) -> Void in
                if let error = error {
                    completion(ids: nil, error: error)
                } else if let stories = json as? [Int] {
                    completion(ids: stories, error: nil)
                }
        }
    }
    
    func getStory(id: Int, completion: (story: Story?, error: NSError?) -> Void) -> Request {
        let request =  Alamofire
            .request(.GET, baseURLString + "/v0/item/\(id).json")
            .responseJSON { (_, _, json, error) -> Void in
                if let error = error {
                    completion(story: nil, error: error)
                } else {
                    completion(story: Story(json: JSON(json!)), error: nil)
                }
        }
        request.request.cachePolicy
        return request
    }
    
}
