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
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.hnfd.background")
        let manager =  Alamofire.Manager(configuration: configuration)
        return manager
    }()
    
    static func download(_ request: URLRequestConvertible, destinationURL: URL) -> Request {
        let downloadDestination: Request.DownloadFileDestination = { (tempURL, response) -> URL in
            let fileManager = FileManager.default
            if let destinationPath = destinationURL.path
                , fileManager.fileExists(atPath: destinationPath) {
                do {
                    try fileManager.removeItem(atPath: destinationPath)
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
    
    static let responseProcessingQueue = OperationQueue()
    
    static func downloadStories(_ type: StoriesType, completion: ((Result<[Story], Error>) -> Void)?) {
        let request = HNFDRouter.stories(type: type)
        Cache.shared().diskCache.fileURL(forKey: type.cacheKey) { (cache, key, result, fileURL) in
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
                    DispatchQueue.main.async {
                        print("Total bytes read on main queue: \(totalBytesRead)")
                    }
                }
                .validate()
                .response { request, response, data, error in
                    if let error = error {
                        completion?(Result.failure(Error.external(underlying: error)))
                    }
                    // seems data is reserved for resumes...
                    // if there is a completion, serialize object at path
                    if let completion = completion,
                        let filePath = fileURL.path,
                        let data = FileManager.default.contents(atPath: filePath) {
                        
                        self.responseProcessingQueue.addOperation({ () -> Void in
                            let stories = JSON(data: data).arrayValue
                                .filter { return $0 != nil } // dirty fix for cleaning out null stories from response. did not go with failable initializer on Story  because there's a bug in the swift compiler that makes it hard to fail initializer on class objects.
                                .map { Story(json: $0) }
                            OperationQueue.main.addOperation({ () -> Void in
                                completion(Result.success(stories))
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
    
    case stories(type: StoriesType)
    case story(id: Int)
    
    var method: Alamofire.Method {
        switch self {
        default:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .stories(let type):
            return "\(type.rawValue)"
        case .story(let id):
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
        let URL = Foundation.URL(string: Private.Constants.HNAPIBaseURLString)!
        let mutableURLRequest = NSMutableURLRequest(url: URL.appendingPathComponent(path))
        mutableURLRequest.httpMethod = method.rawValue
        //        todo: clever header shit for caching?
        return Alamofire.ParameterEncoding.url.encode(mutableURLRequest, parameters: parameters).0
    }
}

enum ReadabilityRouter: URLRequestConvertible {
    
    case article(URL: URL)
    
    var method: Alamofire.Method {
        switch self {
        default:
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .article:
            return "/content/v1/parser"
        }
    }
    
    var parameters: [String: AnyObject] {
        switch self {
        case .article(let URL):
            return [
                "url": URL as AnyObject,
                "token": Private.Keys.readabilityParserAPIToken as AnyObject
            ]
        }
    }
    
    // MARK: URLRequestConvertible
    
    var URLRequest: NSMutableURLRequest {
        let URL = Foundation.URL(string: "https://readability.com/api")!
        let mutableURLRequest = NSMutableURLRequest(url: URL.appendingPathComponent(path))
        mutableURLRequest.httpMethod = method.rawValue
        return Alamofire.ParameterEncoding.url.encode(mutableURLRequest, parameters: parameters).0
    }
}
