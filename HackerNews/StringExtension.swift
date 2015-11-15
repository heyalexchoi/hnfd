//
//  StringExtension.swift
//  HackerNews
//
//  Created by Alex Choi on 11/14/15.
//  Copyright © 2015 Alex Choi. All rights reserved.
//

import Foundation

extension String {
    
    static func htmlStringHyperlink(URL: NSURL, text: String) -> String {
        let string: String = URL.absoluteString ?? ""
        let quotedString = "\"" + string + "\""
        return "<a href=\(quotedString)>\(text)</a>"
    }
}