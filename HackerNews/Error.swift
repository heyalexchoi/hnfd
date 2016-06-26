//
//  Public.swift
//  HackerNews
//
//  Created by Alex Choi on 8/14/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//
extension Error: ErrorType {}

enum Error: Int {
    
    static let messagesKey = "messages"
    static let hnfdDomain = "hnfd"
    
    case UnableToCreateReachability
    
    var description: String {
        switch self {
        case .UnableToCreateReachability: return "Unable to create reachabilitiy"
        }
    }
    
    var error: NSError {
        return NSError(domain: Error.hnfdDomain,
                       code: rawValue,
                       userInfo: [NSLocalizedDescriptionKey: description])
    }    
}