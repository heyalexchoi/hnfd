//
//  Extensions.swift
//  HackerNews
//
//  Created by alexchoi on 4/16/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

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

extension NSAttributedString {
    
    convenience init(htmlString: String) {
        let attributedString = NSAttributedString(data: (htmlString as NSString).dataUsingEncoding(NSUTF8StringEncoding)!,
            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding],
            documentAttributes: nil, error: nil)!
        self.init(attributedString: attributedString)
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
