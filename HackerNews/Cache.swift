//
//  Cache.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import PromiseKit

struct Cache {
    
    static let shared = Cache()
    static let cacheName = "com.heyalexchoi.hnfd.cache"
    
    let backgroundQueue = OperationQueue()
    let completionReturnQueue = OperationQueue.main
    let fileManager = FileManager.default
    
    let cacheURL: URL = {
        let fileManager = FileManager.default
        let cachesDirectory = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let cacheURL = NSURL.fileURL(withPathComponents: [cachesDirectory.path, Cache.cacheName])!
        if !fileManager.fileExists(atPath: cacheURL.path) {
            try! fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        return cacheURL
    }()
    
    func fileURL(forKey key: String) -> URL {
        return cacheURL.appendingPathComponent(key)
    }
    
    private func data(forKey key: String) throws -> Data {
        return try Data(contentsOf: fileURL(forKey: key))
    }
    
    func getObject<T: ResponseObjectSerializable>(forKey key: String, completion: @escaping (_ result: Result<T>) -> Void) {
        backgroundQueue.addOperation {
            do {
                let data = try self.data(forKey: key)
                ResponseObjectSerializer.serialize(data: data, completion: completion)
            } catch let error {
                self.complete(error: error, completion: completion)
            }
        }
    }
    
    func getObjects<T: ResponseObjectSerializable>(forKey key: String, completion: @escaping (_ result: Result<[T]>) -> Void) {
        backgroundQueue.addOperation {
            do {
                let data = try self.data(forKey: key)
                ResponseObjectSerializer.serialize(data: data, completion: completion)
            } catch let error {
                self.complete(error: error, completion: completion)
            }
        }
    }
    
    func setObject<T: DataSerializable>(forKey key: String, object: T) {
        backgroundQueue.addOperation {
            do {
                try object.asData.write(to: self.fileURL(forKey: key))
            } catch let error {
                debugPrint("cache set object error: \(error)")
            }
        }
    }
    
    func setObjects<T: JSONSerializable>(forKey key: String, objects: [T]) {
        backgroundQueue.addOperation {
            do {
                let jsonArray = objects.map({ (object) -> Any in
                    return object.asJSON
                })
                
                let data = try JSONSerialization.data(withJSONObject: jsonArray, options: [])
                try data.write(to: self.fileURL(forKey: key))
            } catch let error {
                debugPrint("cache set object error: \(error)")
            }
        }
    }
    
    // MARK: - STORIES
    
    func getStories(_ type: StoriesType, completion: @escaping (_ result: Result<[Story]>) -> Void) {
        getObjects(forKey: type.rawValue, completion: completion)
    }
    
    func getStories(withType type: StoriesType) -> Promise<[Story]> {
        return Promise { (fulfill: @escaping ([Story]) -> Void, reject: @escaping (Error) -> Void) in
            getStories(type, completion: { (result) in
                guard let stories = result.value else {
                    reject(result.error!)
                    return
                }
                fulfill(stories)
            })
        }
    }
    
    func setStories(_ type: StoriesType, stories: [Story]) {
        setObjects(forKey: type.cacheKey, objects: stories)
    }
    
    func getStories(ids: [Int], timeout: TimeInterval = 2) -> Promise<[Story]> {
        return Promise { (fulfill: @escaping ([Story]) -> Void, reject: @escaping (Error) -> Void) in
            
            _ = after(interval: timeout).then(execute: { (_) -> Void in
                reject(HNFDError.timeout)
            })
            
            let promises = ids.map({ (id) -> Promise<Story> in
                return getStory(id: id)
            })
            
            let combinedPromises = when(resolved: promises)
                
            _ = combinedPromises
                .then(execute: { (results: [PromiseKit.Result<Story>]) -> Void in
                var stories = [Story]()
                for case let .fulfilled(story) in results {
                    stories.append(story)
                }
                fulfill(stories.orderBy(ids: ids))
            })
        }
    }
    
    // MARK: - PINNED STORIES
    
    func getPinnedStoryIds(completion: @escaping (_ result: Result<[Int]>) -> Void) {
        getObjects(forKey: Story.pinnedIdsCacheKey, completion: completion)
    }
    
    func setPinnedStoryIds(ids: [Int]) {
        setObjects(forKey: Story.pinnedIdsCacheKey, objects: ids)
    }
    
    func addPinnedStory(id: Int) {
        getPinnedStoryIds { (result: Result<[Int]>) in
            var pinnedIds = result.value ?? [Int]()
            if let pinnedIdIndex = pinnedIds.index(where: { (pinnedId) -> Bool in
                return pinnedId == id
            }) {
                pinnedIds.remove(at: pinnedIdIndex)
            }
            pinnedIds.insert(id, at: 0)
            self.setPinnedStoryIds(ids: pinnedIds)
        }
    }
    
    func removePinnedStory(id: Int) {
        getPinnedStoryIds { (result: Result<[Int]>) in
            var pinnedIds = result.value ?? [Int]()
            if let pinnedIdIndex = pinnedIds.index(where: { (pinnedId) -> Bool in
                return pinnedId == id
            }) {
                pinnedIds.remove(at: pinnedIdIndex)
            }
            self.setPinnedStoryIds(ids: pinnedIds)
        }
    }
    
    // MARK: - STORY
    
    func getStory(_ id: Int, completion: @escaping (_ result: Result<Story>) -> Void) {
        getObject(forKey: Story.cacheKey(id), completion: completion)
    }
    
    func getStory(id: Int) -> Promise<Story> {
        return Promise { (fulfill: @escaping (Story) -> Void, reject: @escaping (Error) -> Void) in
            getStory(id, completion: { (result) in
                guard let story = result.value else {
                    reject(result.error!)
                    return
                }
                fulfill(story)
            })
        }
    }
    
    func setStory(_ story: Story) {
        setObject(forKey: story.cacheKey, object: story)
    }
    
    // MARK: - ARTICLES
    
    func getArticle(_ story: Story, completion: @escaping (_ result: Result<MercuryArticle>) -> Void) {
        guard let cacheKey = story.articleCacheKey else {
            completion(Result.failure(HNFDError.storyHasNoArticleURL))
            return
        }
        getObject(forKey: cacheKey, completion: completion)
    }
    
    func setArticle(_ article: MercuryArticle) {
        setObject(forKey: article.cacheKey, object: article)
    }
}

extension Cache {
    
    func complete<T: Any>(error: Error, completion: @escaping (Result<T>) -> Void) {
        self.completionReturnQueue.addOperation {
            completion(Result.failure(error))
        }
    }
}

extension Cache {
    
    func hasFileCachedItemForKey(_ key: String?) -> Bool {
        guard let key = key else { return false }
        return fileManager.fileExists(atPath: fileURL(forKey: key).path)
    }
}
