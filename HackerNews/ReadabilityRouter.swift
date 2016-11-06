//
//  ReadabilityRouter.swift
//  HackerNews
//
//  Created by alexchoi on 11/2/16.
//  Copyright © 2016 Alex Choi. All rights reserved.
//

import Foundation
import Alamofire

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
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: "https://readability.com/api")!.appendingPathComponent(path)
        var request = try URLEncoding.default.encode(URLRequest(url: url), with: parameters)
        request.httpMethod = method.rawValue
        return request
    }
}
