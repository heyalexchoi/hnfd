//
//  Extensions.swift
//  HackerNews
//
//  Created by alexchoi on 4/16/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import NYXImagesKit
import UIImage_Additions

struct Shared {
    static let prototypeView = UIView()
}

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

extension UIImage {
    
    class func downChevron() -> UIImage {
        return UIImage.add_imageNamed("down_chevron", tintColor: UIColor.textColor(), style: ADDImageTintStyleKeepingAlpha).scaleToFitSize(CGSize(width: 15, height: 15))
    }
    
    class func pushPin() -> UIImage {
        return UIImage.add_imageNamed("push_pin_4", tintColor: UIColor.textColor(), style: ADDImageTintStyleKeepingAlpha).scaleToFitSize(CGSize(width: 15, height: 15))
    }
}

extension String {
    
    static func htmlStringHyperlink(URL: NSURL, text: String) -> String {
        let string: String = URL.absoluteString ?? ""
        let quotedString = "\"" + string + "\""
        return "<a href=\(quotedString)>\(text)</a>"
    }
}

extension NSURL {
    
    func hyperlinkWithText(text: String) -> String {
        return String.htmlStringHyperlink(self, text: text)
    }
    
    func hyperlink() -> String {
        return self.hyperlinkWithText(self.absoluteString ?? "")
    }
}

func merge<K,V>(dicts: [K: V]...) -> [K: V] {
    var new = [K: V]()
    for dict in dicts {
        for (k,v) in dict {
            new[k] = v
        }
    }
    return new
}

func pmap<T,U>(array: Array<T>, closure: (T) -> U) -> Array<U> {
    var pmapped = Array<U>()
    dispatch_apply(array.count, dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0)) { (i) -> Void in
        pmapped.append(closure(array[i]))
    }
    return pmapped
}
