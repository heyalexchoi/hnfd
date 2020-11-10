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
        return UIColor.iceberg()
    }
    
    class func backgroundColor() -> UIColor {
        return UIColor.charcoal()
    }
    
    class func hnSeparatorColor() -> UIColor {
        return UIColor.coolGray()
    }
    
    class func tintColor() -> UIColor {
        return Shared.prototypeView.tintColor
    }
    
}
