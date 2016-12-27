//
//  MercuryRouter.swift
//  HackerNews
//
//  Created by alexchoi on 11/2/16.
//  Copyright © 2016 Alex Choi. All rights reserved.
//

import Foundation
import Alamofire

enum MercuryRouter: URLRequestConvertible {
    
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
            return "/parser"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .article(let URLString):
            return [
                "url": URLString
            ]
        }
    }
    
    // MARK: URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: "https://mercury.postlight.com")!.appendingPathComponent(path)
        var request = try URLEncoding.default.encode(URLRequest(url: url), with: parameters)
        request.httpMethod = method.rawValue
        request.addValue(Private.Keys.mercuryParserAPIToken, forHTTPHeaderField: "x-api-key")
        return request
    }
}
