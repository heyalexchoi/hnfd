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

protocol Downloadable {
    var cacheKey: String { get }
}

protocol JSONSerializable {
    init?(json: JSON)
}

struct Downloader {
    
    static let backgroundManager: Alamofire.Manager = {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.hnfd.background")
        let manager =  Alamofire.Manager(configuration: configuration)
        return manager
    }()
    
    static func download(request: URLRequestConvertible, destinationURL: NSURL) -> Request {
        let downloadDestination: Request.DownloadFileDestination = { (tempURL, response) -> NSURL in
            let fileManager = NSFileManager.defaultManager()
            if let destinationPath = destinationURL.path
                where fileManager.fileExistsAtPath(destinationPath) {
                do {
                    try fileManager.removeItemAtPath(destinationPath)
                } catch {
                    print("file manager could not remove item at path \(destinationPath)")
                }
            }
            return destinationURL
        }
        let request = backgroundManager.download(request, destination: downloadDestination)
        
        return request
    }
}

extension Downloader {
    
    static let responseProcessingQueue = NSOperationQueue()
    
    static func downloadStories(type: StoriesType, completion: ((Result<[Story], Error>) -> Void)?) {
        let request = HNFDRouter.Stories(type: type)
        Cache.sharedCache().diskCache.fileURLForKey(type.cacheKey) { (cache, key, result, fileURL) in
            guard let fileURL = fileURL else {
                print("downloader failed to get file path for stories type \(type.title)")
                return
            }
            self.download(request, destinationURL: fileURL)
                .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                    print(totalBytesRead)
                    // probs wont keep this
                    // This closure is NOT called on the main queue for performance
                    // reasons. To update your ui, dispatch to the main queue.
                    dispatch_async(dispatch_get_main_queue()) {
                        print("Total bytes read on main queue: \(totalBytesRead)")
                    }
                }
                .validate()
                .response { request, response, data, error in
                    if let error = error {
                        completion?(Result.Failure(Error.External(underlying: error)))
                    }
                    // seems data is reserved for resumes...
                    // if there is a completion, serialize object at path
                    if let completion = completion,
                        let filePath = fileURL.path,
                        let data = NSFileManager.defaultManager().contentsAtPath(filePath) {
                        
                        self.responseProcessingQueue.addOperationWithBlock({ () -> Void in
                            let stories = JSON(data: data).arrayValue
                                .filter { return $0 != nil } // dirty fix for cleaning out null stories from response. did not go with failable initializer on Story  because there's a bug in the swift compiler that makes it hard to fail initializer on class objects.
                                .map { Story(json: $0) }
                            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                                completion(Result.Success(stories))
                            })
                        })
                    }
                }
                .debugPrint()
        }
    }
}

extension Request {
    func debugPrint() -> Request {
        print("debug description: \(debugDescription)")
        return self
    }
}

enum HNFDRouter: URLRequestConvertible {
    
    case Stories(type: StoriesType)
    case Story(id: Int)
    
    var method: Alamofire.Method {
        switch self {
        default:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .Stories(let type):
            return "\(type.rawValue)"
        case .Story(let id):
            return "/items/\(id)"
        }
    }
    
    var parameters: [String: AnyObject] {
        switch self {
        default:
            return [:]
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: Private.Constants.HNAPIBaseURLString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        //        todo: clever header shit for caching?
        return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
    }
}

enum ReadabilityRouter: URLRequestConvertible {
    
    case Article(URL: NSURL)
    
    var method: Alamofire.Method {
        switch self {
        default:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .Article:
            return "/content/v1/parser"
        }
    }
    
    var parameters: [String: AnyObject] {
        switch self {
        case .Article(let URL):
            return [
                "url": URL,
                "token": Private.Keys.readabilityParserAPIToken
            ]
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: "https://readability.com/api")!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
    }
}