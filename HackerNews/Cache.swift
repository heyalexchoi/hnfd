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
        debugPrint("cache url: ")
        debugPrint(cacheURL)
        if !fileManager.fileExists(atPath: cacheURL.path) {
            try! fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
            print("created cache directory!")
        }
        
        return cacheURL
    }()
    
    func fileURL(forKey key: String) -> URL {
        return cacheURL.appendingPathComponent(key)
    }
    
//    func data(forKey key: String, completion: @escaping (_ result: Result<Data>) -> Void) {
//        backgroundQueue.addOperation {
//            do {
//                let dataForKey = try self.data(forKey: key)
//                self.mainQueue.addOperation {
//                    completion(Result.success(dataForKey))
//                }
//            } catch let error {
//                self.mainQueue.addOperation {
//                    completion(Result.failure(error))
//                }
//            }
//        }
//    }
    
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
