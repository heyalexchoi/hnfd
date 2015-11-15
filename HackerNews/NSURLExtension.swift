//
//  NSURLExtension.swift
//  HackerNews
//
//  Created by Alex Choi on 11/14/15.
//  Copyright © 2015 Alex Choi. All rights reserved.
//

import Foundation

extension NSURL {
    
    func hyperlinkWithText(text: String) -> String {
        return String.htmlStringHyperlink(self, text: text)
    }
    
    func hyperlink() -> String {
        return self.hyperlinkWithText(self.absoluteString ?? "")
    }
}
