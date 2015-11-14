//
//  UIFontExtensions.swift
//  HackerNews
//
//  Created by Alex Choi on 11/14/15.
//  Copyright © 2015 Alex Choi. All rights reserved.
//

import Foundation

extension UIFont {
    
    class func textFont() -> UIFont {
        return UIFont(name: "Avenir-Medium", size: 16)!
    }
    
    class func detailFont() -> UIFont {
        return UIFont(name: "Avenir-Light", size: 14)!
    }
    
    class func textReaderFont() -> UIFont {
        return UIFont(name: "Avenir-Book", size: 18)!
    }
    
    class func titleFont() -> UIFont {
        return UIFont(name: "Avenir-Heavy", size: 20)!
    }
    
}