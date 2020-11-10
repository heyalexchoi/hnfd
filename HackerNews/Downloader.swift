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
import PromiseKit

typealias Result = Swift.Result

struct Downloader {
    // just converted to alamofire 5, for swift 5. apparently alamofire does not yet support
    // background downloads https://github.com/Alamofire/Alamofire/issues/2743

//    static let backgroundSessionIdentifier =  "com.hnfd.background"
//
//    static let backgroundManager: Alamofire.Session = {
//        let configuration = URLSessionConfiguration.background(withIdentifier: backgroundSessionIdentifier)
//        let manager =  Alamofire.Session(configuration: configuration)
//        return manager
//    }()
    
    static func download(_ request: URLRequestConvertible, destinationURL: URL) -> DownloadRequest {
        let downloadDestination: DownloadRequest.Destination = { (_, _) -> (destinationURL: URL, options: DownloadRequest.Options) in
            return (destinationURL,  [.createIntermediateDirectories, .removePreviousFile])
        }
        // just converted to alamofire 5, for swift 5. apparently alamofire does not yet support
        // background downloads https://github.com/Alamofire/Alamofire/issues/2743
//        let downloadRequest = backgroundManager.download(request, to: downloadDestination)
        let downloadRequest = AF.download(request, to: downloadDestination)
        return downloadRequest
    }
}


extension Downloader {
    /* Downloads file for request to destination URL, and serializes result to provided response object serializable type */
    @discardableResult static func download<T: ResponseObjectSerializable>(_ request: URLRequestConvertible, destinationURL: URL, completion: ((_ result: Result<T, Error>) -> Void)?) -> DownloadRequest {
        return download(request, destinationURL: destinationURL)
            .validate()
            // .downloadProgress can also be inserted here
            .responseJSON(completionHandler: { (response) in
                guard let completion = completion else { return }
                ResponseObjectSerializer.serialize(response: response, completion: completion)
                ResponseObjectSerializer.serialize(response: response, completion: completion)
            })
    }
    /* Downloads file for request to destination URL, and serializes result to provided response object serializable type */
    @discardableResult static func download<T: ResponseObjectSerializable>(_ request: URLRequestConvertible, destinationURL: URL, completion: ((_ result: Result<[T], Error>) -> Void)?) -> DownloadRequest {
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
    
    @discardableResult static func downloadStory(_ id: Int, completion: ((_ result: Result<Story, Error>) -> Void)?) -> DownloadRequest {
        let request = HNPWARouter.item(id: id)
        let fileURL = DataSource.cache.fileURL(forKey: Story.cacheKey(id))
        return download(request, destinationURL: fileURL, completion: completion)
    }
    
    static func downloadStory(id: Int) -> Promise<Story> {
        return Promise { seal in
            downloadStory(id) { (result) in
                switch result {
                case .success(let story):
                    seal.fulfill(story)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    @discardableResult static func downloadStories(_ type: StoriesType, page: Int, completion: ((_ result: Result<[Story], Error>) -> Void)?) -> DownloadRequest {
        let request = HNPWARouter.stories(type: type, page: page)
        let fileURL = DataSource.cache.fileURL(forKey: type.cacheKey(page: page))
        return download(request, destinationURL: fileURL, completion: completion)
    }
    
    static func downloadStories(withType type: StoriesType, page: Int) -> Promise<[Story]> {
        return Promise { seal in
            downloadStories(type, page: page) { (result) in
                switch result {
                case .success(let stories):
                    seal.fulfill(stories)
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
    
    @discardableResult static func download(stories ids: [Int], completion: ((_ result: Result<[Story], Error>) -> Void)?) -> [DownloadRequest] {
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
            return downloadStory(id, completion: { (result: Result<Story, Error>) in
                switch result {
                case .success(let story):
                    stories.append(story)
                case .failure:
                    failureCount += 1
                }
                completeIfFinished()
            })
        }
    }
}
// MARK: - Article
extension Downloader {
    
    @discardableResult static func downloadArticle(URLString: String, completion: ((_ result: Result<MercuryArticle, Error>) -> Void)?) -> DownloadRequest {
        let request = MercuryRouter.article(URLString: URLString)
        let fileURL = DataSource.cache.fileURL(forKey: MercuryArticle.cacheKeyForURLString(URLString))
        return download(request, destinationURL: fileURL, completion: completion)
    }
}
