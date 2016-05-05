//
//  APIClient.swift
//  HackerNews
//
//  Created by Alex Choi on 5/1/16.
//  Copyright © 2016 Alex Choi. All rights reserved.
//

import Foundation
import Alamofire

struct APIClient {
    
    let backgroundManager: Alamofire.Manager = {
        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.hnfd.background")
        return Alamofire.Manager(configuration: configuration)
    }()
    
    func download(request: URLRequestConvertible, destinationURL: NSURL) {
        let downloadDestination: Request.DownloadFileDestination = { (_,_) -> NSURL in
            return destinationURL
        }
        backgroundManager.download(request, destination: downloadDestination)
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
        //            mutableURLRequest.setValue("", forHTTPHeaderField: "field") // clever header shit?
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
        //            mutableURLRequest.setValue("", forHTTPHeaderField: "field") // clever header shit?
        return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
    }
}