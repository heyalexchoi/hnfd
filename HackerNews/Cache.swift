//
//  Cache.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//
import PINCache
import SwiftyJSON

class Cache: PINCache {
    
    func object<T: ResponseObjectSerializable>(forKey key: String, completion: @escaping (_ result: Result<T>) -> Void) {
        object(forKey: key) { (cache, key, value) in
            ResponseObjectSerializer.serialize(any: value, completion: completion)
        }
    }
    
    func objects<T: ResponseObjectSerializable>(forKey key: String, completion: @escaping (_ result: Result<[T]>) -> Void) {
        object(forKey: key) { (cache, key, value) in            
            ResponseObjectSerializer.serialize(any: value, completion: completion)
        }
    }
    
    // MARK: - STORIES
    
    func getStories(_ type: StoriesType, completion: @escaping (_ result: Result<[Story]>) -> Void) {
        objects(forKey: type.rawValue, completion: completion)
    }
    
    func setStories(_ type: StoriesType, stories: [Story]) {
        let jsonStories = stories.map { $0.asJSON }
        let archivedStories = NSKeyedArchiver.archivedData(withRootObject: jsonStories)
        setObject(archivedStories as NSCoding, forKey: type.rawValue, block: nil)
    }
    
    // MARK: - STORY
    
    func getStory(_ id: Int, completion: @escaping (_ result: Result<Story>) -> Void) {
        object(forKey: Story.cacheKey(id), completion: completion)
    }
    
    func setStory(_ story: Story) {
        setObject(story.asJSON, forKey: story.cacheKey, block: nil)
        // TO DO: error handling??
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
