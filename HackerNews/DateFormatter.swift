//
//  DateFormatter.swift
//  HackerNews
//
//  Created by Alex Choi on 7/12/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

struct DateFormatter {
    
    static let sharedFormatter = NSDateFormatter()
    
    static func dateFromString(string: String, format: String) -> NSDate? {
        sharedFormatter.dateFormat = format
        return sharedFormatter.dateFromString(string)
    }
    
    static func stringFromDate(date: NSDate, format: String) -> String {
        sharedFormatter.dateFormat = format
        return sharedFormatter.stringFromDate(date)
    }
}
