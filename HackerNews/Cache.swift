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
    
    func getObject<T: ResponseObjectSerializable>(forKey key: String, completion: @escaping (_ result: Result<T, Error>) -> Void) {
        backgroundQueue.addOperation {
            do {
                let data = try self.data(forKey: key)
                ResponseObjectSerializer.serialize(data: data, completion: completion)
            } catch let error {
                self.complete(error: error, completion: completion)
            }
        }
    }
    
    func getObjects<T: ResponseObjectSerializable>(forKey key: String, completion: @escaping (_ result: Result<[T], Error>) -> Void) {
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
    
    func getStories(_ type: StoriesType, page: Int, completion: @escaping (_ result: Result<[Story], Error>) -> Void) {
        getObjects(forKey: type.cacheKey(page: page), completion: completion)
    }
    
    func getStories(withType type: StoriesType, page: Int) -> Promise<[Story]> {
        return Promise { seal in
            getStories(type, page: page, completion: { (result) in
                switch result {
                case .success(let stories):
                    seal.fulfill(stories)
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }
    
    func setStories(_ type: StoriesType, page: Int, stories: [Story]) {
        setObjects(forKey: type.cacheKey(page: page), objects: stories)
    }
    
    func getStories(ids: [Int], timeout: TimeInterval = 2) -> Promise<[Story]> {
        return Promise { seal in
            let timeoutPromise = after(seconds: timeout)
            
            let promises = ids.map({ (id) -> Promise<Story> in
                return getStory(id: id)
            })
            let combinedPromises = when(resolved: promises)
                .done { (results: [PromiseKit.Result<Story>]) -> Void in
                var stories = [Story]()
                for case let .fulfilled(story) in results {
                    stories.append(story)
                }
                seal.fulfill(stories.orderBy(ids: ids))
            }
            
            race(timeoutPromise, combinedPromises).done {
                seal.reject(HNFDError.timeout)
            }
        }
    }
    
    // MARK: - PINNED STORIES
    
    func getPinnedStoryIds(completion: @escaping (_ result: Result<[Int], Error>) -> Void) {
        getObjects(forKey: Story.pinnedIdsCacheKey, completion: completion)
    }
    
    func setPinnedStoryIds(ids: [Int]) {
        setObjects(forKey: Story.pinnedIdsCacheKey, objects: ids)
    }
    
    // MARK: - STORY
    
    func getStory(_ id: Int, completion: @escaping (_ result: Result<Story, Error>) -> Void) {
        getObject(forKey: Story.cacheKey(id), completion: completion)
    }
    
    func getStory(id: Int) -> Promise<Story> {
        return Promise { seal in
            getStory(id, completion: { (result) in
                switch result {
                case .success(let story):
                    seal.fulfill(story)
                case .failure(let error):
                    seal.reject(error)
                }
            })
        }
    }
    
    func setStory(_ story: Story) {
        setObject(forKey: story.cacheKey, object: story)
    }
    
    // MARK: - ARTICLES
    
    func getArticle(_ story: Story, completion: @escaping (_ result: Result<MercuryArticle, Error>) -> Void) {
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
    
    func complete<T: Any>(error: Error, completion: @escaping (Result<T, Error>) -> Void) {
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

class SharedState {
    
    static let shared = SharedState()
    
    private let cache = Cache.shared
    private(set) var pinnedStoryIds = [Int]()
    
    init() {
        cache.getPinnedStoryIds { [weak self] (result: Result<[Int], Error>) in
            switch result {
            case .success(let ids):
                self?.pinnedStoryIds = ids
            case .failure:
                self?.pinnedStoryIds = [Int]()
            }
        }
    }
    
    // Mark: - Pinned Ids
    
    func indexForPinnedStory(id: Int) -> Int? {
        return pinnedStoryIds.index(where: { (pinnedId) -> Bool in
            return pinnedId == id
        })
    }
    
    func isStoryIdPinned(id: Int) -> Bool {
        return indexForPinnedStory(id: id) != nil
    }
    
    func addPinnedStory(id: Int) {
        if let pinnedIdIndex = indexForPinnedStory(id: id) {
            pinnedStoryIds.remove(at: pinnedIdIndex)
        }
        pinnedStoryIds.insert(id, at: 0)
        cache.setPinnedStoryIds(ids: pinnedStoryIds)
    }

    func removePinnedStory(id: Int) {
        if let pinnedIdIndex = indexForPinnedStory(id: id) {
            pinnedStoryIds.remove(at: pinnedIdIndex)
        }
        cache.setPinnedStoryIds(ids: pinnedStoryIds)
    }
}
