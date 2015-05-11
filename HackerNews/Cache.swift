//
//  Cache.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import TMCache

let errorDomain = "HNFD Error Domain"

class Cache: TMCache {
    
    let readabilityAPIClient = ReadabilityAPIClient()
    let hnAPIClient = HNAPIClient()
    
    func cachedStory(story: Story, completion: (Story?) -> Void) {
        objectForKey(story.storyCacheKey, block: { (Cache, key, value) -> Void in
            completion(value as? Story)
        })
    }
    
    func isStoryCached(story: Story, completion: (Bool) -> Void) {
        diskCache.fileURLForKey(story.storyCacheKey, block: { (Cache, key, value, url) -> Void in
            completion(url != nil)
        })
    }
    
    func cachedArticle(story: Story, completion: (ReadabilityArticle?) -> Void) {
        objectForKey(story.articleCacheKey, block: { (cache, key, value) -> Void in
            completion(value as? ReadabilityArticle)
        })
    }
    
    func isArticleCached(story: Story, completion: (Bool) -> Void) {
        diskCache.fileURLForKey(story.articleCacheKey, block: { (_, _, _, url) -> Void in
            completion(url != nil)
        })
    }
    
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
    Fetches full story from network. If story is saved, updates value in cache.
    If story could not be fetched, falls back on cached value if available. 
    If no cached value, completes with any fetching related errors.
    
    TO DO: change behavior depending on reachability - fetch immediately from cache if connectivity is poor.
    */
    func fullStoryForStory(story: Story, completion: ((story: Story?, error: NSError?) -> Void)?) -> NSURLSessionTask  {
        return hnAPIClient.getStory(story.id, completion: { [weak self] (fetchedStory, error) -> Void in
            if let fetchedStory = fetchedStory {
                completion?(story: fetchedStory, error: nil)
                if story.saved {
                    self?.setObject(fetchedStory, forKey: story.storyCacheKey, block: nil)
                }
            } else {
                self?.cachedStory(story, completion: { (story) -> Void in
                    if let story = story {
                        completion?(story: story, error: nil)
                    } else if let error = error {
                        completion?(story: nil, error: error)
                    }
                })
            }
            }).task
    }
    
}