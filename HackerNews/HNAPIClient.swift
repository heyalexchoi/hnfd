//
//  HNAPIClient.swift
//  HackerNews
//
//  Created by alexchoi on 4/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import Foundation
import Alamofire

class HNAPIClient {
    
    static let sharedClient = HNAPIClient()
    let baseURLString = "https://hacker-news.firebaseio.com"
    
    func getTopStories(completion: (stories: [Int]?, error: NSError?) -> Void) -> Request {
        return Alamofire
            .request(.GET, baseURLString + "/v0/topstories.json")
            .responseJSON { (_, _, JSON, error) -> Void in
                completion(stories: JSON as? [Int], error: error)
        }
    }
    
    func getItem(id: Int, completion: (item: AnyObject?, error: NSError?) -> Void) -> Request {
        return Alamofire
            .request(.GET, baseURLString + "/v0/item/\(id).json")
            .responseJSON { (_, _, JSON, error) -> Void in
                completion(item: JSON, error: error)
        }
    }
    
    
}