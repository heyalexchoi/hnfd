//
//  APIClient.swift
//  HackerNews
//
//  Created by Alex Choi on 5/1/16.
//  Copyright © 2016 Alex Choi. All rights reserved.
//

import Foundation
import Alamofire

struct Downloader {
    
    static let backgroundManager: Alamofire.Manager = {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.hnfd.background")
        let manager =  Alamofire.Manager(configuration: configuration)
        return manager
    }()
    
    static func download(request: URLRequestConvertible, destinationURL: NSURL) -> Request {
        let downloadDestination: Request.DownloadFileDestination = { (_,_) -> NSURL in
            return destinationURL
        }
        return backgroundManager.download(request, destination: downloadDestination)
    }
}

extension Downloader {
    
    static func downloadStories(type: StoriesType, completion: (result: Result<[Story], Error>) -> Void) {
        let request = HNFDRouter.Stories(type: type)
        Cache.sharedCache().diskCache.fileURLForKey(type.cacheKey) { (cache, key, result, fileURL) in
            guard let fileURL = fileURL else {
                print("downloader failed to get file path for storie type \(type.title)")
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
                .response { request, response, data, error in
                    if let error = error {
                        print("Failed with error: \(error)")
                    } else {
                        print("Downloaded file successfully \nrequest: \(request)\nresponse: \(response)\ndata: \(data)")
                    }
            }
        }
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