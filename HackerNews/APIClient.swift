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
    static func request<T: ResponseObjectSerializable>(_ request: URLRequestConvertible, completion: @escaping ((_ result: Result<T, Error>) -> Void)) -> Request {
        return AF.request(request).responseJSON { response in
            ResponseObjectSerializer.serialize(response: response, completion: completion)
        }
    }
}
