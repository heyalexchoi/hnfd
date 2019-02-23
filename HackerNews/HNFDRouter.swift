//
//  HNFDRouter.swift
//  HackerNews
//
//  Created by alexchoi on 11/2/16.
//  Copyright © 2016 Alex Choi. All rights reserved.
//

import Foundation
import Alamofire

// shut it down! someone else is hosting an api!
// https://github.com/tastejs/hacker-news-pwas/blob/master/docs/api.md
//
//enum HNFDRouter: URLRequestConvertible {
//
//    case stories(type: StoriesType, limit: Int, offset: Int)
//    case story(id: Int)
//
//    var method: Alamofire.HTTPMethod {
//        switch self {
//        default:
//            return .get
//        }
//    }
//
//    var path: String {
//        switch self {
//        case .stories(let type, _, _):
//            return "\(type.rawValue)"
//        case .story(let id):
//            return "/items/\(id)"
//        }
//    }
//
//    var parameters: [String: Any] {
//        switch self {
//        case .stories(_, let limit, let offset):
//            return [
//                "limit": limit,
//                "offset": offset
//            ]
//        default:
//            return [:]
//        }
//    }
//
//    // MARK: URLRequestConvertible
//
//    func asURLRequest() throws -> URLRequest {
//        let url = URL(string: Private.Constants.HNAPIBaseURLString)!.appendingPathComponent(path)
//        var request = try URLEncoding.default.encode(URLRequest(url: url), with: parameters)
//        request.httpMethod = method.rawValue
//        return request
//    }
//}
