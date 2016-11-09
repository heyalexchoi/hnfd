//
//  Cache.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

struct Cache {
    
    static let shared = Cache()
    static let cacheName = "com.heyalexchoi.hnfd.cache"
    
    let backgroundQueue = OperationQueue()
    let mainQueue = OperationQueue.main
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
                completion(Result.failure(error))
            }
        }
    }
    
    func getObjects<T: ResponseObjectSerializable>(forKey key: String, completion: @escaping (_ result: Result<[T]>) -> Void) {
        backgroundQueue.addOperation {
            do {
                let data = try self.data(forKey: key)
                ResponseObjectSerializer.serialize(data: data, completion: completion)
            } catch let error {
                completion(Result.failure(error))
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
    
    func setStories(_ type: StoriesType, stories: [Story]) {
        setObjects(forKey: type.cacheKey, objects: stories)
    }
    
    /*! there is no failure result - this method currently only returns what stories could be retrieved */
    func getStories(ids: [Int], completion: @escaping (_ result: Result<[Story]>) -> Void) {
        // TO DO: errors
        // good lord i should have done this with promisekit
        let startTime = Date()
        let timeOut = 2
        
        var stories = [Story]()
        var failureCount = 0
        
        var completed = false
        
        func completeIfFinished() {
            guard !completed else { return }
            if stories.count + failureCount == ids.count
                || startTime.timeIntervalSinceNow >= TimeInterval(-timeOut) {
                completion(Result.success(stories))
                completed = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(timeOut)) {
            completeIfFinished()
        }
        
        for id in ids {
            guard Story.isCached(id) else {
                failureCount += 1
                completeIfFinished()
                return
            }
            getStory(id, completion: { (result: Result<Story>) in
                guard let story = result.value else {
                    failureCount += 1
                    completeIfFinished()
                    return
                }
                stories.append(story)
                completeIfFinished()
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
    
    // MARK: - STORY
    
    func getStory(_ id: Int, completion: @escaping (_ result: Result<Story>) -> Void) {
        getObject(forKey: Story.cacheKey(id), completion: completion)
    }
    
    func setStory(_ story: Story) {
        setObject(forKey: story.cacheKey, object: story)
    }
    
    // MARK: - ARTICLES
    
    func getArticle(_ story: Story, completion: @escaping (_ result: Result<ReadabilityArticle>) -> Void) {
        guard let cacheKey = story.articleCacheKey else {
            completion(Result.failure(HNFDError.storyHasNoArticleURL))
            return
        }
        getObject(forKey: cacheKey, completion: completion)
    }
    
    func setArticle(_ article: ReadabilityArticle) {
        setObject(forKey: article.cacheKey, object: article)
    }
    
}

extension Cache {
    
    func hasFileCachedItemForKey(_ key: String?) -> Bool {
        guard let key = key else { return false }
        return fileManager.fileExists(atPath: fileURL(forKey: key).path)
    }
}
