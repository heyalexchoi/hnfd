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
    
    static func getStories(type: StoriesType, refresh: Bool = false, completion: (stories: [Story]?, error: NSError?) -> Void) {
        // will use cached stories unless refresh requested (and network available)
        if (!type.isCached || refresh) && shouldMakeNetworkRequest {
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
    
    static func getStory(id: Int, refresh: Bool = false, completion: (story: Story?, error: NSError?) -> Void) {
        // will use cached story unless refresh requested (and network available)
        if (!Story.isCached(id) || refresh) && shouldMakeNetworkRequest {
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
    
    static func getArticle(story: Story, refresh: Bool = false, completion: ((article: ReadabilityArticle?, error: NSError?) -> Void)) {
        guard let URL = story.URL else {
            let error = NSError(domain: errorDomain,
                                code: 420,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Story has no URL, so there is no article to get"])
            completion(article: nil, error: error)
            return
        }
        // articles are generally static. it'll generally be safe (and faster) to grab the article from the cache. if network requests can be made then refresh can override the cache
        if (!story.isArticleCached || refresh) && shouldMakeNetworkRequest {
            readabilityAPIClient.getParsedArticleForURL(URL, completion: { (article, error) in
                guard let article = article else {
                    NSOperationQueue.mainQueue().addOperationWithBlock { completion(article: nil, error: error) }
                    return
                }
                
                cache.setArticle(article, completion: nil)
                NSOperationQueue.mainQueue().addOperationWithBlock {completion(article: article, error: nil) }
            })
        } else {
            cache.getArticle(story, completion: { (article) in
                NSOperationQueue.mainQueue().addOperationWithBlock { completion(article: article, error: nil) }
            })
        }
    }
    
}

extension DataSource {
    
    static func refreshAll(intervalHandler: ((intervalResult: Any?) -> Void)? = nil, completion: (() -> Void)? = nil) {
        // get top stories and maybe selected kinds of stories
        // get all stories and article for each
        let storiesType = StoriesType.Top
        getStories(storiesType, refresh: true) { (stories, error) in
            intervalHandler?(intervalResult: stories)
            guard let stories = stories else {
                // ?
                completion?()
                return
            }
            
            for story in stories {
                getStory(story.id, refresh: true, completion: { (story, error) in
                    intervalHandler?(intervalResult: story)
                    guard let story = story else {
                        // would i even do anything?
                        return
                    }
                })
                getArticle(story, refresh: false, completion: { (article, error) in
                    intervalHandler?(intervalResult: article)
                    guard let article = article else {
                        // ?
                        return
                    }
                })
                // oops i don't have the promise shit to call completion properly
            }
        }
    }
}
