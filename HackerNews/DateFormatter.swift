//
//  DateFormatter.swift
//  HackerNews
//
//  Created by Alex Choi on 7/12/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

struct DateFormatter {
    
    static let sharedFormatter = Foundation.DateFormatter()
    
    static func dateFromString(_ string: String, format: String) -> Date? {
        sharedFormatter.dateFormat = format
        return sharedFormatter.date(from: string)
    }
    
    static func stringFromDate(_ date: Date, format: String) -> String {
        sharedFormatter.dateFormat = format
        return sharedFormatter.string(from: date)
    }
}
