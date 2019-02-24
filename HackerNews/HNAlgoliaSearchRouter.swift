//
//  HNAlgoliaSearchRouter.swift
//  HackerNews
//
//  Created by Alex Choi on 2/22/19.
//  Copyright © 2019 Alex Choi. All rights reserved.
//

import Foundation
import Alamofire

enum HNAlgoliaSearchRouter: URLRequestConvertible {
    
    case search(query: String, page: Int)
    
    var method: Alamofire.HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .search:
            return "/v1/search"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .search(let query, let page):
            return [
                "query": query,
                "tags": "story", // could do comments, or even by author, but static for now
                "page": page
            ]
        }
    }
    
    // MARK: URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: "https://hn.algolia.com/api")!.appendingPathComponent(path)
        var request = try URLEncoding.default.encode(URLRequest(url: url), with: parameters)
        request.httpMethod = method.rawValue
        return request
    }
}
