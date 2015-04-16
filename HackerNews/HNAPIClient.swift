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
    
    func getTopStoryIDs(completion: (ids: [Int]?, error: NSError?) -> Void) -> Request {
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

    /*! asynchronously fetch top story IDs, then asynchronously fetch data for each story. 
    top stories returns 500 ids - pass in valid indices (0...499) for desired stories to be fetched */
    func getTopStories(indices: [Int], completion: (stories: [Story]?, error: NSError?) -> Void) -> [Request] {
        var requests = [Request]()
        getTopStoryIDs { [weak self] (ids, error) -> Void in
            if let error = error {
                completion(stories: nil, error: error)
            } else if let ids = ids {
                var stories = [Story]()
                let selectedIds: [Int] = $.at(ids, indexes: indices)                
                $.each(selectedIds) { (var id: Int) -> Void in
                    if let strong_self = self {
                        let request = strong_self.getStory(id, completion: { (story, error) -> Void in
                            if let error = error {
                                completion(stories: nil, error: error)
                            } else {
                                stories.append(story!)
                                if stories.count == selectedIds.count {
                                    completion(stories: stories, error: nil)
                                }
                            }
                        })
                        requests.append(request)
                    }
                    
                }
            }
        }
        return requests
    }
    
    func getStory(id: Int, completion: (story: Story?, error: NSError?) -> Void) -> Request {
        return Alamofire
            .request(.GET, baseURLString + "/v0/item/\(id).json")
            .responseJSON { (_, _, json, error) -> Void in
                if let error = error {
                    completion(story: nil, error: error)
                } else {
                    completion(story: Story(json: JSON(json!)), error: nil)
                }
        }
    }
    
}
