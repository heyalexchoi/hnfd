//
//  Cache.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import TMCache

let errorDomain = "HNFD Error Domain"

enum CacheFetchPreference {
    case ReturnCacheDataElseLoad,
    FetchRemoteDataAndUpdateCache
}

class Cache: TMCache {
    
    let readabilityAPIClient = ReadabilityAPIClient()
    let hnAPIClient = HNAPIClient()
    
    func cachedStory(story: Story, completion: (Story?) -> Void) {
        objectForKey(story.cacheKey, block: { (Cache, key, value) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completion(value as? Story)
            })
        })
    }
//    
//    func isStoryCached(story: Story, completion: (Bool) -> Void) {
//        diskCache.fileURLForKey(story.cacheKey, block: { (Cache, key, value, url) -> Void in
//            completion(url != nil)
//        })
//    }
    
    func cachedArticle(story: Story, completion: (ReadabilityArticle?) -> Void) {
        objectForKey(story.articleCacheKey, block: { (cache, key, value) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completion(value as? ReadabilityArticle)
            })
        })
    }
    
//    func isArticleCached(story: Story, completion: (Bool) -> Void) {
//        diskCache.fileURLForKey(story.articleCacheKey, block: { (_, _, _, url) -> Void in
//            completion(url != nil)
//        })
//    }
    
    /*!
    Returns cached article if available, otherwise fetches from network.
    If story is saved, saves fetched article to cache.
    If story has no URL, completes with error
    */
    func articleForStory(story: Story, completion: ((article: ReadabilityArticle?, error: NSError?) -> Void)?) -> NSURLSessionTask? {
        var task: NSURLSessionTask?
        if let storyURL = story.URL {
            cachedArticle(story, completion: { [weak self] (article) -> Void in
                if let article = article {
                    completion?(article: article, error: nil)
                } else {
                    task = self?.readabilityAPIClient.getParsedArticleForURL(storyURL, completion: { (article, error) -> Void in
                        if let article = article {
                            completion?(article: article, error: nil)
                            if story.saved {
                                self?.setObject(article, forKey: story.articleCacheKey, block: nil)
                            }
                        } else if let error = error {
                            completion?(article: nil, error: error)
                        }
                    }).task
                }
                })
        } else {
            completion?(article: nil, error: NSError(domain: errorDomain, code: 420, userInfo: [NSLocalizedDescriptionKey: "Story has no URL, so there is no article to get"]))
        }
        return task
    }
    /*!
    Get full story with comments for a story.
    Options allow user to prefer either cached or remote data.
    */
    func fullStoryForStory(story: Story, preference: CacheFetchPreference, completion: ((story: Story?, error: NSError?) -> Void)?) -> NSURLSessionTask?  {
        
        switch preference {
            
        case .FetchRemoteDataAndUpdateCache:
            return hnAPIClient.getStory(story.id, completion: { [weak self] (fetchedStory, error) -> Void in
                if let fetchedStory = fetchedStory {
                    if story.saved { self?.setObject(fetchedStory, forKey: story.cacheKey, block: nil) }
                    completion?(story: fetchedStory, error: nil)
                } else if let error = error {
                    completion?(story: nil, error: error)
                }
                }).task
            
        case .ReturnCacheDataElseLoad:
            cachedStory(story, completion: { [weak self] (cachedStory) -> Void in
                if let cachedStory = cachedStory {
                    completion?(story: cachedStory, error: nil)
                } else {
                    self?.hnAPIClient.getStory(story.id, completion: { (fetchedStory, error) -> Void in
                        if let fetchedStory = fetchedStory {
                            if story.saved { self?.setObject(fetchedStory, forKey: story.cacheKey, block: nil) }
                            completion?(story: fetchedStory, error: nil)
                        } else if let error = error {
                            completion?(story: nil, error: error)
                        }
                    })
                }
                })
            return nil
        }
    }
    
}