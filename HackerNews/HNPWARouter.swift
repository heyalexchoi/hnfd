//
//  HNPWARouter.swift
//  HackerNews
//
//  Created by Alex Choi on 2/23/19.
//  Copyright © 2019 Alex Choi. All rights reserved.
//

import Foundation
import Alamofire

enum HNPWARouter: URLRequestConvertible {
    
    case item(id: Int)
    case stories(type: StoriesType, page: Int)
    
    var method: Alamofire.HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .item(let id):
            return "/v0/item/\(id).json"
        // switched to reportedly less performant endpoint to workaround an api issue resulting in stale data
        // https://twitter.com/_davideast/status/1173927341480800258
        case .stories(let type, _):
            return "/v0/\(type.rawValue).json"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        // switched to reportedly less performant endpoint to workaround an api issue resulting in stale data
        // https://twitter.com/_davideast/status/1173927341480800258
        case .stories(_, let page):
            return ["page": page]
        default:
            return [:]
        }
    }
    
    // MARK: URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: "https://api.hnpwa.com")!.appendingPathComponent(path)
        var request = try URLEncoding.default.encode(URLRequest(url: url), with: parameters)
        request.httpMethod = method.rawValue
        return request
    }
}

