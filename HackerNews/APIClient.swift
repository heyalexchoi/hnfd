//
//  APIClient.swift
//  HackerNews
//
//  Created by Alex Choi on 2/22/19.
//  Copyright © 2019 Alex Choi. All rights reserved.
//

import Alamofire
import SwiftyJSON
import PromiseKit

struct APIClient {
    static func request<T: ResponseObjectSerializable>(_ request: URLRequestConvertible, completion: @escaping ((_ result: Result<T>) -> Void)) -> Request {
        return Alamofire.request(request).responseJSON { response in
            ResponseObjectSerializer.serialize(response: response, completion: completion)
        }
    }
    static func request<T: ResponseObjectSerializable>(_ request: URLRequestConvertible, completion: @escaping ((_ result: Result<[T]>) -> Void)) -> Request {
        return Alamofire.request(request).responseJSON { response in
            ResponseObjectSerializer.serialize(response: response, completion: completion)
        }
    }
//    static func request<T: ResponseObjectSerializable>(_ request: URLRequestConvertible) -> Promise<T> {
//        return Promise { (fulfill: @escaping (T) -> Void, reject: @escaping (Error) -> Void) in
//            self.request(request, completion: { (result) in
//                guard let value = result.value else {
//                    reject(result.error!)
//                    return
//                }
//                fulfill(value)
//            })
//        }
//    }
}
