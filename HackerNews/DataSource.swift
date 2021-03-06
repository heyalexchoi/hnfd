//
//  DataSource.swift
//  HackerNews
//
//  Created by Alex Choi on 4/7/16.
//  Copyright © 2016 Alex Choi. All rights reserved.
//

import Foundation
import Reachability
import PromiseKit

struct DataSource {
    
    static let cache = Cache.shared
    static let reachability: Reachability? = {
        guard let reachability = Reachability() else {
            ErrorController.showErrorNotification(HNFDError.unableToCreateReachability)
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
    
    /* Attempts to download stories with type. In case of timeout or download failure, falls back to cached values. */
    static func getStories(withType type: StoriesType, page: Int, timeout: TimeInterval = 2) -> Promise<[Story]> {
        
        func getStories(withType type: StoriesType) -> Promise<[Story]> {
            guard shouldMakeNetworkRequest else {
                return cache.getStories(withType: type, page: page)
            }
            
            return Downloader.downloadStories(withType: type, page: page)
        }
        
        guard type != .Pinned else {
            return getPinnedStories(page: page)
        }
        
        return Promise { (fulfill: @escaping ([Story]) -> Void, reject: @escaping (Error) -> Void) in
            
            _ = after(interval: timeout)
                .then(execute: { (_) -> Promise<[Story]> in
                    return cache.getStories(withType: type, page: page)
                })
                .then(execute: { (stories) -> Void in
                    fulfill(stories)
                })
                .catch(execute: { (error) in
                    reject(error)
                })
            
            getStories(withType: type)
            .then(execute: { (stories) -> Void in
                fulfill(stories)
            })
            .catch(execute: { (error) in
                cache.getStories(withType: type, page: page)
                .then(execute: { (stories) -> Void in
                    fulfill(stories)
                })
                .catch(execute: { (error) in
                    reject(error)
                })
            })
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
    
    static func getStory(_ id: Int, timeout: TimeInterval = 2) -> Promise<Story> {
        guard shouldMakeNetworkRequest else {
            return cache.getStory(id: id)
        }
        return Promise { (fulfill: @escaping (Story) -> Void, reject: @escaping (Error) -> Void) in
            _ = after(interval: timeout)
                .then(execute: { (_) -> Promise<Story> in
                    return cache.getStory(id: id)
                })
                .then(execute: { (story) -> Void in
                    fulfill(story)
                })
                .catch(execute: { (error) in
                    reject(error)
                })
            
            Downloader.downloadStory(id: id)
                .then(execute: { (story) -> Void in
                    fulfill(story)
                })
                .catch(execute: { (error) in
                    cache.getStory(id: id)
                        .then(execute: { (story) -> Void in
                            fulfill(story)
                        })
                        .catch(execute: { (error) in
                            reject(error)
                        })
                })
        }
    }

    
    // MARK: - PINNED STORIES
    
    fileprivate static func getPinnedStories(page: Int) -> Promise<[Story]> {
        let ids = SharedState.shared.pinnedStoryIds
        return Cache.shared.getStories(ids: ids.paginate(page: page, per_page: 30))
    }
}

extension DataSource {
    
    // MARK: - Articles
    
    static func getArticle(_ story: Story, refresh: Bool = false, completion: ((_ result: Result<MercuryArticle>) -> Void)?) {
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
    
    /* Initiates downloads for article and full story. */
    
    @discardableResult
    static func fullySync(storiesType type: StoriesType, page: Int, timeout: TimeInterval) -> Promise<Void> {
        return Promise<Void> { (fulfill, reject) in
            
            _ = after(interval: timeout)
                .then(execute: { (_) -> Void in
                    reject(HNFDError.timeout)
                })
            
            _ = getStories(withType: type, page: page, timeout: timeout)
            .then(execute: { (stories) -> Promise<Void> in
                return fullySync(stories: stories, timeout: timeout)
            })
            .then(execute: { (_) -> Void in
                fulfill(())
            })
            .catch(execute: { (error) in
                reject(error)
            })
        }
    }
    
    @discardableResult
    static func fullySync(stories: [Story], timeout: TimeInterval) -> Promise<Void> {
        return Promise<Void> { (fulfill, reject) in
            
            _ = after(interval: timeout)
                .then(execute: { (_) -> Void in
                    reject(HNFDError.timeout)
                })
            
            for story in stories {
                fullySync(story: story)
            }
            
            fulfill(())
        }
    }
    
    
    static func fullySync(story: Story) {
        Downloader.downloadStory(story.id, completion: nil)
        if let urlString = story.URLString {
            Downloader.downloadArticle(URLString: urlString, completion: nil)
        }
    }
}
