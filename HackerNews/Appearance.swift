//
//  Appearance.swift
//  HackerNews
//
//  Created by Alex Choi on 4/17/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//


struct TextAttributes {
    static let textAttributes = [NSFontAttributeName: UIFont.textFont(), NSForegroundColorAttributeName: UIColor.textColor()]
    static let textReaderAttributes = [NSFontAttributeName: UIFont.textReaderFont(), NSForegroundColorAttributeName: UIColor.textColor()]
    static let titleAttributes = [NSFontAttributeName: UIFont.titleFont(), NSForegroundColorAttributeName: UIColor.textColor()]
}

struct Appearance {
    
    static func setAppearances() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(color: UIColor.backgroundColor()), forBarMetrics: .Default)
        UINavigationBar.appearance().titleTextAttributes = TextAttributes.titleAttributes
        UINavigationBar.appearance().tintColor = UIColor.textColor()
        
        UIBarButtonItem.appearance().setTitleTextAttributes(TextAttributes.textAttributes, forState: .Normal)
    }
    
}

