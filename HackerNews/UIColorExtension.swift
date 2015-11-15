//
//  ColorExtensions.swift
//  HackerNews
//
//  Created by Alex Choi on 11/14/15.
//  Copyright © 2015 Alex Choi. All rights reserved.
//

import Foundation


extension UIColor {
    
    class func textColor() -> UIColor {
        return UIColor.icebergColor()
    }
    
    class func backgroundColor() -> UIColor {
        return UIColor.charcoalColor()
    }
    
    class func separatorColor() -> UIColor {
        return UIColor.coolGrayColor()
    }
    
    class func tintColor() -> UIColor {
        return Shared.prototypeView.tintColor
    }
    
}