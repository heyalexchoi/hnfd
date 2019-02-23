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
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        default:
            return [:]
        }
    }
    
    // MARK: URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: "https://api.hnpwa.com/")!.appendingPathComponent(path)
        var request = try URLEncoding.default.encode(URLRequest(url: url), with: parameters)
        request.httpMethod = method.rawValue
        return request
    }
}

