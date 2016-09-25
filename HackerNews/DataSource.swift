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
        if type.isCached && !refresh {
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
        if (!Story.isCached(id) || refresh) && shouldMakeNetworkRequest {
            Downloader.downloadStory(id, completion: { (result) in
                completion(result)
            })
        } else {
            cache.getStory(id, completion: { (result) in
                OperationQueue.main.addOperation {
                    completion(result)                    
                }
            })
        }
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
    
//    static func refreshAll(_ intervalHandler: ((_ intervalResult: Any?) -> Void)? = nil, completion: (() -> Void)? = nil) {
//        // get top stories and maybe selected kinds of stories
//        // get all stories and article for each
//        let storiesType = StoriesType.Top
//        getStories(storiesType, refresh: true) { (stories, error) in
//            intervalHandler?(stories)
//            guard let stories = stories else {
//                // ?
//                completion?()
//                return
//            }
//            
//            for story in stories {
//                getStory(story.id, refresh: true, completion: { (story, error) in
//                    intervalHandler?(story)
//                    guard let _ = story else {
//                        // would i even do anything?
//                        return
//                    }
//                })
//                getArticle(story, refresh: false, completion: { (article, error) in
//                    intervalHandler?(article)
//                    guard let _ = article else {
//                        // ?
//                        return
//                    }
//                })
//                // oops i don't have the promise shit to call completion properly
//            }
//        }
//    }
}
