//
//  Public.swift
//  HackerNews
//
//  Created by Alex Choi on 8/14/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//
extension Error: ErrorType {}

enum Error {
    
    static let messagesKey = "messages"
    static let hnfdDomain = "hnfd"
    
    case External(underlying: NSError)
    case UnableToCreateReachability
    
    var description: String {
        switch self {
        case .UnableToCreateReachability:
            return "Unable to create reachabilitiy"
        case .External(let underlying):
            return underlying.localizedDescription
        }
    }
    
    var code: Int {
        switch self {
        case .External(let underlying):
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