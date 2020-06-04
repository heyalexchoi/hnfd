//
//  ResponseObjectSerializer.swift
//  HackerNews
//
//  Created by alexchoi on 11/2/16.
//  Copyright © 2016 Alex Choi. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire


protocol ResponseObjectSerializable {
    init?(json: JSON)
}

protocol DataSerializable {
    var asData: Data { get }
}

protocol JSONSerializable {
    var asJSON: Any { get }
}

struct ResponseObjectSerializer {
    
    static let responseProcessingQueue = OperationQueue()
    static let completionReturnQueue = OperationQueue.main
    
    // MARK: - Serialize Download Responses
    
    /* works with alamofire's request request response json to turn json objects <Any> into a ResponseObjectSerializable model object. Work is performed on response processing queue and completion block results are returned on completion return queue */
    static func serialize<T: ResponseObjectSerializable>(response: Alamofire.AFDownloadResponse<Any>, completion: @escaping (Result<T, Error>) -> Void) {
        
        switch response.result {
        case .success(let json):
            serialize(any: json, completion: completion)
        case .failure(let error):
            complete(error: error, completion: completion)
        }
    }
    
    /* works with alamofire's request request response json to turn json objects <Any> into a an array of ResponseObjectSerializable model objects. Work is performed on response processing queue and completion block results are returned on completion return queue */
    static func serialize<T: ResponseObjectSerializable>(response: Alamofire.AFDownloadResponse<Any>, completion: @escaping (Result<[T], Error>) -> Void) {
        
        switch response.result {
        case .success(let json):
            serialize(any: json, completion: completion)
        case .failure(let error):
            complete(error: error, completion: completion)
        }
    }
    
    /* works with alamofire's request request response json to turn json objects <Any> into a ResponseObjectSerializable model object. Work is performed on response processing queue and completion block results are returned on completion return queue */
    static func serialize<T: ResponseObjectSerializable>(response: Alamofire.AFDataResponse<Any>, completion: @escaping (Result<T, Error>) -> Void) {
        
        switch response.result {
        case .success(let json):
            serialize(any: json, completion: completion)
        case .failure(let error):
            complete(error: error, completion: completion)
        }
    }
    
    /* works with alamofire's request request response json to turn json objects <Any> into a an array of ResponseObjectSerializable model objects. Work is performed on response processing queue and completion block results are returned on completion return queue */
    static func serialize<T: ResponseObjectSerializable>(response: Alamofire.DataResponse<Any, Error>, completion: @escaping (Result<[T], Error>) -> Void) {
        
        switch response.result {
        case .success(let json):
            serialize(any: json, completion: completion)
        case .failure(let error):
            complete(error: error, completion: completion)
        }
    }
    
    // MARK: - Serialize type 'Any' json objects
    
    static func serialize<T: ResponseObjectSerializable>(any: Any, completion: @escaping (Result<[T], Error>) -> Void) {
        
        self.responseProcessingQueue.addOperation({ () -> Void in
            
            let swiftyJSONArray = JSON(any).arrayValue
            
            var serializedArray = [T]()
            
            for json in swiftyJSONArray {
                if let serializedItem = T(json: json) {
                    serializedArray.append(serializedItem)
                }
            }
            
            completionReturnQueue.addOperation {
                completion(Result.success(serializedArray))
            }
        })
    }
    
    static func serialize<T: ResponseObjectSerializable>(any: Any, completion: @escaping (Result<T, Error>) -> Void) {
        
        self.responseProcessingQueue.addOperation({ () -> Void in
            
            let swiftyJSON = JSON(any)
            let serialized = T(json: swiftyJSON)
            
            completionReturnQueue.addOperation {
                
                if let serialized = serialized {
                    completion(Result.success(serialized))
                } else {
                    completion(Result.failure(HNFDError.responseObjectSerializableFailedToInitialize(unserializedObject: any)))
                }
            }
        })
    }
    
    // MARK: - Serialize Data
    
    static func serialize<T: ResponseObjectSerializable>(data: Data, completion: @escaping (Result<T, Error>) -> Void) {
        
        self.responseProcessingQueue.addOperation({ () -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                self.serialize(any: json, completion: completion)
            } catch let error {
                complete(error: error, completion: completion)
            }
        })
    }
    
    static func serialize<T: ResponseObjectSerializable>(data: Data, completion: @escaping (Result<[T], Error>) -> Void) {
        
        self.responseProcessingQueue.addOperation({ () -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
                self.serialize(any: json, completion: completion)
            } catch let error {
                complete(error: error, completion: completion)
            }
        })
    }
    
    // MARK: - Errors
    
    static func complete<T: Any>(error: Error, completion: @escaping (Result<T, Error>) -> Void) {
        self.completionReturnQueue.addOperation {
            completion(Result.failure(error))
        }
    }
}
