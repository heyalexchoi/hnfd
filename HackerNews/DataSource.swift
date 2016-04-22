//
//  DataSource.swift
//  HackerNews
//
//  Created by Alex Choi on 4/7/16.
//  Copyright © 2016 Alex Choi. All rights reserved.
//

import Foundation
import ReachabilitySwift

struct DataSource {
    
    static let readabilityAPIClient = ReadabilityAPIClient()
    static let hnAPIClient = HNAPIClient()
    static let cache = Cache.sharedCache()
    static let reachability: Reachability? = {
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
            return reachability
        } catch {
            print("Unable to create Reachability")
            return nil
        }
    }()
    
    static var shouldMakeNetworkRequest: Bool {
        return reachability?.isReachable() ?? true
    }
}

extension DataSource {
    
    // MARK: - Stories
    
    static func getStories(type: StoriesType, completion: (stories: [Story]?, error: NSError?) -> Void) {
        if shouldMakeNetworkRequest {
            hnAPIClient.getStories(type, limit: 100, offset: 0) { (stories, error) in
                guard let stories = stories else {
                    NSOperationQueue.mainQueue().addOperationWithBlock { completion(stories: nil, error: error) }
                    return
                }
                
                cache.setStories(type, stories: stories, completion: nil)
                NSOperationQueue.mainQueue().addOperationWithBlock { completion(stories: stories, error: nil) }
            }
        } else {
            cache.getStories(type, completion: { (stories) in
                NSOperationQueue.mainQueue().addOperationWithBlock { completion(stories: stories, error: nil) }
            })
        }
    }
    
    static func getStory(id: Int, completion: (story: Story?, error: NSError?) -> Void) {
        if shouldMakeNetworkRequest {
            hnAPIClient.getStory(id) { (story, error) in
                guard let story = story else {
                    NSOperationQueue.mainQueue().addOperationWithBlock { completion(story: nil, error: error) }
                    return
                }
                
                cache.setStory(story, completion: nil)
                NSOperationQueue.mainQueue().addOperationWithBlock { completion(story: story, error: nil) }
            }
        } else {
            cache.getStory(id, completion: { (story) in
                NSOperationQueue.mainQueue().addOperationWithBlock { completion(story: story, error: nil) }
            })
        }
    }
}

extension DataSource {
    
    // MARK: - Articles
    
    static func articleForStory(story: Story, completion: ((article: ReadabilityArticle?, error: NSError?) -> Void)) {
        guard let URL = story.URL else {
            let error = NSError(domain: errorDomain,
                                code: 420,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Story has no URL, so there is no article to get"])
            completion(article: nil, error: error)
            return
        }
        readabilityAPIClient.getParsedArticleForURL(URL, completion: completion)
    }
    
}
