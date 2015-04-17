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
        return UIFont(name: "Avenir-Medium", size: 14)!
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