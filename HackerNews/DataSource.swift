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
    
    static let readabilityAPIClient = ReadabilityAPIClient()
    static let hnAPIClient = HNAPIClient()
    static let cache = Cache.shared()
    static let reachability: Reachability? = {
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
            return reachability
        } catch {
            ErrorController.showErrorNotification(Error.unableToCreateReachability)
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
    
    static func getStories(_ type: StoriesType, refresh: Bool = false, completion: @escaping (_ stories: [Story]?, _ error: Error?) -> Void) {
        if type.isCached && !refresh {
            cache.getStories(type, completion: { (stories) in
                OperationQueue.main.addOperation { completion(stories: stories, error: nil) }
            })
            return
        }
        
        Downloader.downloadStories(type) { (result) in
            completion(stories: result.value, error: result.error)
        }
    }
    
    static func getStory(_ id: Int, refresh: Bool = false, completion: @escaping (_ story: Story?, _ error: NSError?) -> Void) {
        // will use cached story unless refresh requested (and network available)
        if (!Story.isCached(id) || refresh) && shouldMakeNetworkRequest {
            hnAPIClient.getStory(id) { (story, error) in
                guard let story = story else {
                    OperationQueue.main.addOperation { completion(story: nil, error: error) }
                    return
                }
                
                cache.setStory(story, completion: nil)
                OperationQueue.main.addOperation { completion(story: story, error: nil) }
            }
        } else {
            cache.getStory(id, completion: { (story) in
                OperationQueue.main.addOperation { completion(story: story, error: nil) }
            })
        }
    }
}

extension DataSource {
    
    // MARK: - Articles
    
    static func getArticle(_ story: Story, refresh: Bool = false, completion: @escaping ((_ article: ReadabilityArticle?, _ error: NSError?) -> Void)) {
        guard let URL = story.URL else {
            let error = NSError(domain: errorDomain,
                                code: 420,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Story has no URL, so there is no article to get"])
            completion(nil, error)
            return
        }
        // articles are generally static. it'll generally be safe (and faster) to grab the article from the cache. if network requests can be made then refresh can override the cache
        if (!story.isArticleCached || refresh) && shouldMakeNetworkRequest {
            readabilityAPIClient.getParsedArticleForURL(URL, completion: { (article, error) in
                guard let article = article else {
                    OperationQueue.main.addOperation { completion(article: nil, error: error) }
                    return
                }
                
                cache.setArticle(article, completion: nil)
                OperationQueue.main.addOperation {completion(article: article, error: nil) }
            })
        } else {
            cache.getArticle(story, completion: { (article) in
                OperationQueue.main.addOperation { completion(article: article, error: nil) }
            })
        }
    }
    
}

extension DataSource {
    
    static func refreshAll(_ intervalHandler: ((_ intervalResult: Any?) -> Void)? = nil, completion: (() -> Void)? = nil) {
        // get top stories and maybe selected kinds of stories
        // get all stories and article for each
        let storiesType = StoriesType.Top
        getStories(storiesType, refresh: true) { (stories, error) in
            intervalHandler?(stories)
            guard let stories = stories else {
                // ?
                completion?()
                return
            }
            
            for story in stories {
                getStory(story.id, refresh: true, completion: { (story, error) in
                    intervalHandler?(story)
                    guard let story = story else {
                        // would i even do anything?
                        return
                    }
                })
                getArticle(story, refresh: false, completion: { (article, error) in
                    intervalHandler?(article)
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
