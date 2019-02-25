//
//  StringExtension.swift
//  HackerNews
//
//  Created by Alex Choi on 11/14/15.
//  Copyright © 2015 Alex Choi. All rights reserved.
//

import Foundation

extension String {
    
    static func htmlStringHyperlink(_ URL: Foundation.URL, text: String) -> String {
        let string: String = URL.absoluteString 
        let quotedString = "\"" + string + "\""
        return "<a href=\(quotedString)>\(text)</a>"
    }
    
    var isValidURL: Bool {
        guard let url = Foundation.URL(string: self) else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
}

extension NSAttributedString {
    
    func appending(_ attributedString: NSAttributedString) -> NSAttributedString {
        let mutableAttributedString = self.mutableCopy() as! NSMutableAttributedString
        mutableAttributedString.append(attributedString)
        return mutableAttributedString
    }
}
