//
//  Cache.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//
import PINCache

class Cache: PINCache {
    
    // MARK: - STORIES 
    
    func getStories(_ type: StoriesType, completion: @escaping (_ stories: [Story]?) -> Void) {
        object(forKey: type.rawValue) { (cache, key, value) in
            completion(value as? [Story])
        }
    }
    
    func setStories(_ type: StoriesType, stories: [Story], completion: PINCacheObjectBlock?) {
        setObject(stories as NSCoding, forKey: type.rawValue, block: completion)
    }
    
    // MARK: - STORY
    
    func getStory(_ id: Int, completion: @escaping (Story?) -> Void) {
        object(forKey: Story.cacheKey(id), block: { (Cache, key, value) -> Void in
            completion(value as? Story)
        })
    }
    
    func setStory(_ story: Story, completion: PINCacheObjectBlock?) {
        setObject(story, forKey: story.cacheKey, block: completion)
    }
    
    // MARK: - ARTICLES
    
    func getArticle(_ story: Story, completion: @escaping (ReadabilityArticle?) -> Void) {
        guard let cacheKey = story.articleCacheKey else {
            completion(nil)
            return
        }
        object(forKey: cacheKey, block: { (cache, key, value) -> Void in
            completion(value as? ReadabilityArticle)
        })
    }
    
    func setArticle(_ article: ReadabilityArticle, completion: PINCacheObjectBlock?) {
        setObject(article, forKey: article.cacheKey, block: completion)
    }

}

extension Cache {
    
    func hasFileCachedItemForKey(_ key: String?) -> Bool {
        return diskCache.fileURL(forKey: key) != nil
    }
}
