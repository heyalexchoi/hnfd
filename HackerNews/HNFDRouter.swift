//
//  HNFDRouter.swift
//  HackerNews
//
//  Created by alexchoi on 11/2/16.
//  Copyright © 2016 Alex Choi. All rights reserved.
//

import Foundation
import Alamofire


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
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: Private.Constants.HNAPIBaseURLString)!.appendingPathComponent(path)
        var request = try URLEncoding.default.encode(URLRequest(url: url), with: parameters)
        request.httpMethod = method.rawValue
        return request
    }
}
