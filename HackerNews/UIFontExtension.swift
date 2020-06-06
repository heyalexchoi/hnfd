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
    
    class func largeTitleFont() -> UIFont {
        return UIFont(name: "Avenir-Heavy", size: 48)!
    }
    
    class func symbolFont() -> UIFont {
        return UIFont(name: "Menlo-Regular", size: 18)!
    }
}
