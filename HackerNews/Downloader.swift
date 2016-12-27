//
//  APIClient.swift
//  HackerNews
//
//  Created by Alex Choi on 5/1/16.
//  Copyright © 2016 Alex Choi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias Result = Alamofire.Result

protocol Downloadable {
    var cacheKey: String { get }
}

struct Downloader {
    
    static let backgroundSessionIdentifier =  "com.hnfd.background"
    
    static let backgroundManager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.background(withIdentifier: backgroundSessionIdentifier)
        let manager =  Alamofire.SessionManager(configuration: configuration)
        return manager
    }()
    
    static func download(_ request: URLRequestConvertible, destinationURL: URL) -> DownloadRequest {
        let downloadDestination: DownloadRequest.DownloadFileDestination = { (_, _) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            return (destinationURL,  [.createIntermediateDirectories, .removePreviousFile])
        }
        
        let downloadRequest = backgroundManager.download(request, to: downloadDestination)
        debugPrint(downloadRequest)
        return downloadRequest
    }
}


extension Downloader {
    /* Downloads file for request to destination URL, and serializes result to provided response object serializable type */
    @discardableResult static func download<T: ResponseObjectSerializable>(_ request: URLRequestConvertible, destinationURL: URL, completion: ((_ result: Result<T>) -> Void)?) -> DownloadRequest {
        return download(request, destinationURL: destinationURL)
            .validate()
            // .downloadProgress can also be inserted here
            .responseJSON(completionHandler: { (response) in
                guard let completion = completion else { return }
                ResponseObjectSerializer.serialize(response: response, completion: completion)
            })
    }
    /* Downloads file for request to destination URL, and serializes result to provided response object serializable type */
    @discardableResult static func download<T: ResponseObjectSerializable>(_ request: URLRequestConvertible, destinationURL: URL, completion: ((_ result: Result<[T]>) -> Void)?) -> DownloadRequest {
        return download(request, destinationURL: destinationURL)
            .validate()
            // .downloadProgress can also be inserted here
            .responseJSON(completionHandler: { (response) in
                guard let completion = completion else { return }
                ResponseObjectSerializer.serialize(response: response, completion: completion)
            })
    }
}
// MARK: - Story
extension Downloader {
    
    @discardableResult static func downloadStory(_ id: Int, completion: ((_ result: Result<Story>) -> Void)?) -> DownloadRequest {
        let request = HNFDRouter.story(id: id)
        let fileURL = DataSource.cache.fileURL(forKey: Story.cacheKey(id))
        return download(request, destinationURL: fileURL, completion: completion)
    }
    
    @discardableResult static func downloadStories(_ type: StoriesType, completion: ((_ result: Result<[Story]>) -> Void)?) -> DownloadRequest {
        let request = HNFDRouter.stories(type: type)
        let fileURL = DataSource.cache.fileURL(forKey: type.cacheKey)
        return download(request, destinationURL: fileURL, completion: completion)
    }
    
    @discardableResult static func download(stories ids: [Int], completion: ((_ result: Result<[Story]>) -> Void)?) -> [DownloadRequest] {
        // could proably promisekit this
        
        let startTime = Date()
        let timeOut = 3
        
        var stories = [Story]()
        var failureCount = 0
        
        var completed = false
        
        func completeIfFinished() {
            guard !completed else { return }
            if stories.count + failureCount == ids.count
                || startTime.timeIntervalSinceNow < TimeInterval(-timeOut) {
                
                completion?(Result.success(stories.orderBy(ids: ids)))
                completed = true
            }
        }
        
        return ids.map { (id) -> DownloadRequest in
            return downloadStory(id, completion: { (result: Result<Story>) in
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
}
// MARK: - Article
extension Downloader {
    
    @discardableResult static func downloadArticle(URLString: String, completion: ((_ result: Result<MercuryArticle>) -> Void)?) -> DownloadRequest {
        let request = MercuryRouter.article(URLString: URLString)
        let fileURL = DataSource.cache.fileURL(forKey: MercuryArticle.cacheKeyForURLString(URLString))
        return download(request, destinationURL: fileURL, completion: completion)
    }
}
