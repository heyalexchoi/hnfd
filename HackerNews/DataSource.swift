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
        do {
            return try Reachability()
        } catch {
            ErrorController.showErrorNotification(HNFDError.unableToCreateReachability)
            return nil
        }
    }()
    
    static var shouldMakeNetworkRequest: Bool {
        guard let reachability = reachability else {
            return true
        }
        return reachability.connection != .unavailable // prevent requests without connection. also entry point to prevent network requests for any other reasons
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
        
        return Promise { seal in
            _ = after(seconds: timeout)
                .then { (_) -> Promise<[Story]> in
                    return cache.getStories(withType: type, page: page)
                }
                .done { stories in
                    seal.fulfill(stories)
                }
                .catch { error in
                    seal.reject(error)
                }
            
            getStories(withType: type)
            .done { (stories) -> Void in
                seal.fulfill(stories)
            }
            .catch { error in
                cache.getStories(withType: type, page: page)
                .done { stories in
                    seal.fulfill(stories)
                }
                .catch { error in
                    seal.reject(error)
                }
            }
        }
    }
    
    static func getStory(_ id: Int, refresh: Bool = false, completion: ((_ result: Result<Story, Error>) -> Void)?) {
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
        return Promise { seal in
            _ = after(seconds: timeout)
                .then { (_) -> Promise<Story> in
                    return cache.getStory(id: id)
                }
                .done { story in
                    seal.fulfill(story)
                }
                .catch { error in
                    seal.reject(error)
                }
            
            Downloader.downloadStory(id: id)
                .done { story in
                    seal.fulfill(story)
                }
                .catch({ (error) in
                    cache.getStory(id: id)
                        .done { story in
                            seal.fulfill(story)
                        }
                        .catch { error in
                            seal.reject(error)
                        }
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
    
    static func getArticle(_ story: Story, refresh: Bool = false, completion: ((_ result: Result<MercuryArticle, Error>) -> Void)?) {
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
        return Promise<Void> { seal in
            
            let timeoutPromise = after(seconds: timeout)
            
            let syncChain = getStories(withType: type, page: page, timeout: timeout)
            .then( { (stories) -> Promise<Void> in
                return fullySync(stories: stories, timeout: timeout)
            })
            .done { (_) -> Void in
                seal.fulfill(())
            }
            .recover { error in
                seal.reject(error)
            }.asVoid()
            
            race(syncChain, timeoutPromise).done {
                seal.reject(HNFDError.timeout)
            }
        }
    }
    
    @discardableResult
    static func fullySync(stories: [Story], timeout: TimeInterval) -> Promise<Void> {
        return Promise<Void> { seal in
            after(seconds: timeout).done {
                seal.reject(HNFDError.timeout)
            }            
            for story in stories {
                fullySync(story: story)
            }
            seal.fulfill(())
        }
    }
    
    
    static func fullySync(story: Story) {
        Downloader.downloadStory(story.id, completion: nil)
        if let urlString = story.URLString {
            Downloader.downloadArticle(URLString: urlString, completion: nil)
        }
    }
}
