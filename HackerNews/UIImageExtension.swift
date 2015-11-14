//
//  UIImageExtensions.swift
//  HackerNews
//
//  Created by Alex Choi on 11/14/15.
//  Copyright © 2015 Alex Choi. All rights reserved.
//

import Foundation
import NYXImagesKit
import UIImage_Additions


extension UIImage {
    
    class func downChevron() -> UIImage {
        return UIImage.add_imageNamed("down_chevron", tintColor: UIColor.textColor(), style: ADDImageTintStyleKeepingAlpha).scaleToFitSize(CGSize(width: 15, height: 15))
    }
    
    class func pushPin() -> UIImage {
        return UIImage.add_imageNamed("push_pin_4", tintColor: UIColor.textColor(), style: ADDImageTintStyleKeepingAlpha).scaleToFitSize(CGSize(width: 15, height: 15))
    }
}
