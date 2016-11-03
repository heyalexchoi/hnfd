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
    
    static func getStories(_ type: StoriesType, refresh: Bool = false, completion: @escaping ((_ result: Result<[Story]>) -> Void)) {
        
        guard shouldMakeNetworkRequest && (!type.isCached || refresh) else {
            cache.getStories(type, completion: { (result) in
                OperationQueue.main.addOperation { completion(result) }
            })
            return
        }
        
        Downloader.downloadStories(type) { (result) in
            completion(result)
        }
    }
    
    static func getStory(_ id: Int, refresh: Bool = false, completion: @escaping (_ result: Result<Story>) -> Void) {
        // will use cached story unless refresh requested (and network available)
        guard shouldMakeNetworkRequest && (!Story.isCached(id) || refresh) else {
            cache.getStory(id, completion: { (result) in
                OperationQueue.main.addOperation { completion(result) }
            })
            return
        }
        
        Downloader.downloadStory(id, completion: { (result) in
            completion(result)
        })
    }
}

extension DataSource {
    
    // MARK: - Articles
    
    static func getArticle(_ story: Story, refresh: Bool = false, completion: @escaping ((_ result: Result<ReadabilityArticle>) -> Void)) {
        guard let URLString = story.URLString else {
            completion(Result.failure(HNFDError.storyHasNoArticleURL))
            return
        }
        // articles are generally static. it'll generally be safe (and faster) to grab the article from the cache. if network requests can be made then refresh can override the cache
        if (!story.isArticleCached || refresh) && shouldMakeNetworkRequest {
            Downloader.downloadArticle(URLString: URLString, completion: completion)
        } else {
            cache.getArticle(story, completion: completion)
        }
    }    
}

extension DataSource {
    // promise kit would make this whole thing a lot less shitty. is there promise reducing?
    @discardableResult static func fullySync(storiesType type: StoriesType, completion: ((_ storyResult: Result<Story>, _ articleResult: Result<ReadabilityArticle>) -> Void)?) {
        getStories(type) { (storiesResult: Result<[Story]>) in
            guard let stories = storiesResult.value else {
                completion?(Result.failure(storiesResult.error!), Result.failure(storiesResult.error!))
                return
            }
            
            for story in stories {
                fullySync(story: story.id, completion: completion)
            }
        }
    }
    
    @discardableResult static func fullySync(story id: Int, completion: ((_ storyResult: Result<Story>, _ articleResult: Result<ReadabilityArticle>) -> Void)?) {
        // this could be problem prone - background task has 30 seconds to start all needed downloads and readability article is dependent on story
        getStory(id, refresh: true) { (storyResult: Result<Story>) in
            
            guard let story = storyResult.value else {
                completion?(Result.failure(storyResult.error!), Result.failure(storyResult.error!))
                return
            }
            
            getArticle(story, completion: { (articleResult: Result<ReadabilityArticle>) in
                guard let article = articleResult.value else {
                    completion?(Result.success(story), Result.failure(articleResult.error!))
                    return
                }
                completion?(Result.success(story), Result.success(article))
            })
        }
    }
}
