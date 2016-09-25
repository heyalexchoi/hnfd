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
    
    static let backgroundManager: Alamofire.SessionManager = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "com.hnfd.background")
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

protocol ResponseObjectSerializable {
    init?(json: JSON)
}

protocol DataSerializable {
    var asData: Data { get }
}

protocol JSONSerializable {
    var asJSON: Any { get }
}

struct ResponseObjectSerializer {
    
    static let responseProcessingQueue = OperationQueue()
    static let completionReturnQueue = OperationQueue.main
    
    // MARK: - Serialize Download Responses
    
    /* works with alamofire's request request response json to turn json objects <Any> into a ResponseObjectSerializable model object. Work is performed on response processing queue and completion block results are returned on completion return queue */
    static func serialize<T: ResponseObjectSerializable>(response: Alamofire.DownloadResponse<Any>, completion: @escaping (Result<T>) -> Void) {
        
        switch response.result {
        case .success(let json):
            serialize(any: json, completion: completion)
        case .failure(let error):
            completion(Result.failure(error))
        }
    }
    
    /* works with alamofire's request request response json to turn json objects <Any> into a an array of ResponseObjectSerializable model objects. Work is performed on response processing queue and completion block results are returned on completion return queue */
    static func serialize<T: ResponseObjectSerializable>(response: Alamofire.DownloadResponse<Any>, completion: @escaping (Result<[T]>) -> Void) {
        
        switch response.result {
        case .success(let json):
            serialize(any: json, completion: completion)
        case .failure(let error):
            completion(Result.failure(error))
        }
    }
    
    // MARK: - Serialize type 'Any' json objects
    
    static func serialize<T: ResponseObjectSerializable>(any: Any, completion: @escaping (Result<[T]>) -> Void) {
        
        self.responseProcessingQueue.addOperation({ () -> Void in
            
            let swiftyJSON = JSON(json: any).arrayValue
            
            let serialized = swiftyJSON
                .filter { return $0 != nil } // dirty fix for cleaning out null stories from response. did not go with failable initializer on Story  because there's a bug in the swift compiler that makes it hard to fail initializer on class objects. TO DO: allow failable initializer on model objects
                .map({ (json) -> T? in
                    return T(json: json)
                })
                .filter({ (responseObjectSerializable) -> Bool in
                    return responseObjectSerializable != nil
                })
                .map({ (optionalResponsesObjectSerializable) -> T in
                    return optionalResponsesObjectSerializable!
                })
            
            completionReturnQueue.addOperation {
                completion(Result.success(serialized))
            }
        })
    }
    
    static func serialize<T: ResponseObjectSerializable>(any: Any, completion: @escaping (Result<T>) -> Void) {
        
        self.responseProcessingQueue.addOperation({ () -> Void in
            
            let swiftyJSON = JSON(json: any)
            let serialized = T(json: swiftyJSON)
            
            completionReturnQueue.addOperation {
                
                if let serialized = serialized {
                    completion(Result.success(serialized))
                } else {
                    completion(Result.failure(HNFDError.responseObjectSerializableFailedToInitialize(unserializedObject: any)))
                }
            }
        })
    }
    
    static func serialize<T: ResponseObjectSerializable>(data: Data, completion: @escaping (Result<T>) -> Void) {
        
        self.responseProcessingQueue.addOperation({ () -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                self.serialize(any: json, completion: completion)
            } catch let error {
                completion(Result.failure(error))
            }
        })
    }
    
    static func serialize<T: ResponseObjectSerializable>(data: Data, completion: @escaping (Result<[T]>) -> Void) {
        
        self.responseProcessingQueue.addOperation({ () -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                self.serialize(any: json, completion: completion)
            } catch let error {
                completion(Result.failure(error))
            }
        })
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
}
// MARK: - Article
extension Downloader {
    
    @discardableResult static func downloadArticle(URLString: String, completion: ((_ result: Result<ReadabilityArticle>) -> Void)?) -> DownloadRequest {
        let request = ReadabilityRouter.article(URLString: URLString)
        let fileURL = DataSource.cache.fileURL(forKey: ReadabilityArticle.cacheKeyForURLString(URLString))
        return download(request, destinationURL: fileURL, completion: completion)
    }
}

enum HNFDRouter: URLRequestConvertible {
    
    case stories(type: StoriesType)
    case story(id: Int)
    
    var method: Alamofire.HTTPMethod {
        switch self {
        default:
            return .get
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
    
    func asURLRequest() -> URLRequest {
        let URL = Foundation.URL(string: Private.Constants.HNAPIBaseURLString)!.appendingPathComponent(path)
        //        todo: clever header shit for caching?
        return Alamofire.request(URL, method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).request!
    }
}

enum ReadabilityRouter: URLRequestConvertible {
    
    case article(URLString: String)
    
    var method: Alamofire.HTTPMethod {
        switch self {
        default:
            return .get
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
        case .article(let URLString):
            return [
                "url": URLString as AnyObject,
                "token": Private.Keys.readabilityParserAPIToken as AnyObject
            ]
        }
    }
    
    // MARK: URLRequestConvertible
    
    func asURLRequest() -> URLRequest {
        let URL = Foundation.URL(string: "https://readability.com/api")!.appendingPathComponent(path)
        return Alamofire.request(URL, method: method, parameters: parameters, encoding: URLEncoding.default, headers: nil).request!
    }
}
