//
//  Public.swift
//  HackerNews
//
//  Created by Alex Choi on 8/14/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

//extension Error: Error {}

enum Error {
    
    static let messagesKey = "messages"
    static let hnfdDomain = "hnfd"
    
    case external(underlying: NSError)
    case unableToCreateReachability
    
    var description: String {
        switch self {
        case .unableToCreateReachability:
            return "Unable to create reachabilitiy"
        case .external(let underlying):
            return underlying.localizedDescription
        }
    }
    
    var code: Int {
        switch self {
        case .external(let underlying):
            return underlying.code
        default:
            return 420
        }
    }
    
    var domain: String {
        switch self {
        default:
            return Error.hnfdDomain
        }
    }
    
    var error: NSError {
        return NSError(domain: domain,
                       code: code,
                       userInfo: [NSLocalizedDescriptionKey: description])
    }    
}
