//
//  Cache.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import TMCache

class Cache: TMCache {
    
    // MARK: - STORIES 
    
    func getStories(type: StoriesType, completion: (stories: [Story]?) -> Void) {
        objectForKey(type.rawValue) { (cache, key, value) in
            completion(stories: value as? [Story])
        }
    }
    
    func setStories(type: StoriesType, stories: [Story], completion: TMCacheObjectBlock?) {
        setObject(stories, forKey: type.rawValue, block: completion)
    }
    
    // MARK: - STORY
    
    func getStory(id: Int, completion: (Story?) -> Void) {
        objectForKey(Story.cacheKey(id), block: { (Cache, key, value) -> Void in
            completion(value as? Story)
        })
    }
    
    func setStory(story: Story, completion: TMCacheObjectBlock?) {
        setObject(story, forKey: story.cacheKey, block: completion)
    }
    
    // MARK: - ARTICLES
    
    func getArticle(story: Story, completion: (ReadabilityArticle?) -> Void) {
        objectForKey(story.articleCacheKey, block: { (cache, key, value) -> Void in
            completion(value as? ReadabilityArticle)
        })
    }
    
    func setArticle(article: ReadabilityArticle, completion: TMCacheObjectBlock?) {
        setObject(article, forKey: article.cacheKey, block: completion)
    }

}

extension Cache {
    
    func hasFileCachedItemForKey(key: String?) -> Bool {
        return diskCache.fileURLForKey(key) != nil
    }
}