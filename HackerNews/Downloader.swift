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

extension Downloader {
    
    static let responseProcessingQueue = OperationQueue()
    
    static func downloadStories(_ type: StoriesType, completion: ((_ stories: [Story]?, _ error: HNFDError?) -> Void)?) {
        let request = HNFDRouter.stories(type: type)
        let fileURL = Cache.shared().diskCache.encodedFileURL(forKey: type.cacheKey)
        self.download(request, destinationURL: fileURL)
            .downloadProgress { progress in
                print(progress)
                // probs wont keep this
                // This closure is NOT called on the main queue for performance
                // reasons. To update your ui, dispatch to the main queue.
                DispatchQueue.main.async {
                    debugPrint("Total bytes read on main queue: \(progress)")
                }
            }
            .validate()
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success(let data):
                    // TO DO: this can probably be extracted into a response serializer that takes a type and response  - and returns success(serialized instance of type)/error
                    self.responseProcessingQueue.addOperation({ () -> Void in
                        let stories = JSON(data: data).arrayValue
                            .filter { return $0 != nil } // dirty fix for cleaning out null stories from response. did not go with failable initializer on Story  because there's a bug in the swift compiler that makes it hard to fail initializer on class objects.
                            .map { Story(json: $0) }
                        OperationQueue.main.addOperation({ () -> Void in
                            completion?(stories, nil)
                        })
                    })
                case .failure(let error):
                    // TO DO: better error handling?
                    debugPrint(error)
                    completion?(nil, (error as! HNFDError)) // is this ok?
                }
            })
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
    
    case article(URL: URL)
    
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
        case .article(let URL):
            return [
                "url": URL as AnyObject,
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
