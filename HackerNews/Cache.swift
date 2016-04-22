//
//  Cache.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import TMCache

class Cache: TMCache {
    
    func getStories(type: StoriesType, completion: (stories: [Story]?) -> Void) {
        objectForKey(type.rawValue) { (cache, key, value) in
            completion(stories: value as? [Story])
        }
    }
    
    func setStories(type: StoriesType, stories: [Story], completion: TMCacheObjectBlock?) {
        setObject(stories, forKey: type.rawValue, block: completion)
    }
    
    func getStory(id: Int, completion: (Story?) -> Void) {
        objectForKey(Story.cacheKey(id), block: { (Cache, key, value) -> Void in
            completion(value as? Story)
        })
    }
    
    func setStory(story: Story, completion: TMCacheObjectBlock?) {
        setObject(story, forKey: story.cacheKey, block: completion)
    }
    
    func cachedArticle(story: Story, completion: (ReadabilityArticle?) -> Void) {
        objectForKey(story.articleCacheKey, block: { (cache, key, value) -> Void in
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completion(value as? ReadabilityArticle)
            })
        })
    }
}