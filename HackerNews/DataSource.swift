//
//  DataSource.swift
//  HackerNews
//
//  Created by Alex Choi on 4/7/16.
//  Copyright © 2016 Alex Choi. All rights reserved.
//

import Foundation
import Reachability

struct DataSource {
    
    static let cache = Cache.shared
    static let reachability: Reachability? = {
        guard let reachability = Reachability() else {
            ErrorController.showErrorNotification(HNFDError.unableToCreateReachability)
            print("Unable to create Reachability")
            return nil
        }
        return reachability
    }()
    
    static var shouldMakeNetworkRequest: Bool {
        return reachability?.isReachable ?? true // prevent requests without connection. also entry point to prevent network requests for any other reasons
    }
}

extension DataSource {
    
    // MARK: - Stories
    
    static func getStories(_ type: StoriesType, refresh: Bool = false, completion: ((_ result: Result<[Story]>) -> Void)?) {
        
        guard shouldMakeNetworkRequest && (!type.isCached || refresh) else {
            cache.getStories(type, completion: { (result) in
                OperationQueue.main.addOperation { completion?(result) }
            })
            return
        }
        
        Downloader.downloadStories(type) { (result) in
            completion?(result)
        }
    }
    
    static func getStory(_ id: Int, refresh: Bool = false, completion: ((_ result: Result<Story>) -> Void)?) {
        // will use cached story unless refresh requested (and network available)
        guard shouldMakeNetworkRequest && (!Story.isCached(id) || refresh) else {
            cache.getStory(id, completion: { (result) in
                OperationQueue.main.addOperation { completion?(result) }
            })
            return
        }
        
        Downloader.downloadStory(id, completion: { (result) in
            completion?(result)
        })
    }
    
    // MARK: - PINNED STORIES
    
    /*! this method currently has no failure results. it only returns whatever stories are pinned and could be retrieved */
    static func getPinnedStories(limit: Int, offset: Int, refresh: Bool = false, completion: ((_ result: Result<[Story]>) -> Void)?) {
        // TO DO: errors
        Cache.shared.getPinnedStoryIds { (result: Result<[Int]>) in
            // TO DO: limit and offset
            let ids = result.value ?? [Int]() // TO DO: errors?
            guard shouldMakeNetworkRequest && refresh else {
                Cache.shared.getStories(ids: ids, completion: { (result: Result<[Story]>) in
                    guard let stories = result.value else {
                        completion?(Result.success([Story]()))
                        return
                    }
                    completion?(Result.success(stories))
                })
                return
            }
            
            Downloader.download(stories: ids, completion: { (result: Result<[Story]>) in
                guard let stories = result.value else {
                    completion?(Result.success([Story]()))
                    return
                }
                completion?(Result.success(stories))
            })
        }
    }
}

extension DataSource {
    
    // MARK: - Articles
    
    static func getArticle(_ story: Story, refresh: Bool = false, completion: ((_ result: Result<ReadabilityArticle>) -> Void)?) {
        guard let URLString = story.URLString else {
            completion?(Result.failure(HNFDError.storyHasNoArticleURL))
            return
        }
        // articles are generally static. it'll generally be safe (and faster) to grab the article from the cache. if network requests can be made then refresh can override the cache
        if (!story.isArticleCached || refresh) && shouldMakeNetworkRequest {
            Downloader.downloadArticle(URLString: URLString, completion: completion)
        } else if let completion = completion {
            cache.getArticle(story, completion: completion)
        }
    }    
}

extension DataSource {
    
    @discardableResult static func fullySync(storiesType type: StoriesType,
                                             storiesHandler: ((_ storiesResult: Result<[Story]>) -> Void)?,
                                             storyHandler: ((_ storyResult: Result<Story>) -> Void)?,
                                             articleHandler: ((_ articleResult: Result<ReadabilityArticle>) -> Void)?) {
        
        getStories(type, refresh: true, completion: { (storiesResult: Result<[Story]>) -> Void in
            guard let stories = storiesResult.value else {
                storiesHandler?(Result.failure(storiesResult.error!))
                return
            }
            
            for story in stories {
                fullySync(story: story, storyHandler: storyHandler, articleHandler: articleHandler)
            }
            
            storiesHandler?(Result.success(stories))
        })
    }
    
    @discardableResult static func fullySync(story: Story,
                                             storyHandler: ((_ storyResult: Result<Story>) -> Void)?,
                                             articleHandler: ((_ articleResult: Result<ReadabilityArticle>) -> Void)?) {
        
        getStory(story.id, refresh: true, completion: storyHandler)
        getArticle(story, completion: articleHandler)
    }
}
