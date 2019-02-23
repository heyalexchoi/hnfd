//
//  Appearance.swift
//  HackerNews
//
//  Created by Alex Choi on 4/17/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import DTCoreText
import TSMessages

struct TextAttributes {
    
    static let textAttributes = [NSFontAttributeName: UIFont.textFont(), NSForegroundColorAttributeName: UIColor.textColor()]
    static let detailAttributes = [NSFontAttributeName: UIFont.detailFont(), NSForegroundColorAttributeName: UIColor.textColor()]
    static let textReaderAttributes = [NSFontAttributeName: UIFont.textReaderFont(), NSForegroundColorAttributeName: UIColor.textColor()]
    static let titleAttributes = [NSFontAttributeName: UIFont.titleFont(), NSForegroundColorAttributeName: UIColor.textColor()]
    static let centerAlignment: [String: AnyObject] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return [NSParagraphStyleAttributeName: paragraphStyle]
    }()
    static func URLAttributes(_ URL: Foundation.URL) -> [String: AnyObject] {
        return [DTLinkAttribute: URL as AnyObject]
    }
}

struct Appearance {
    
    static func setAppearances() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(color: UIColor.backgroundColor()), for: .default)
        UINavigationBar.appearance().titleTextAttributes = TextAttributes.titleAttributes
        UINavigationBar.appearance().tintColor = UIColor.textColor()
        UIBarButtonItem.appearance().setTitleTextAttributes(TextAttributes.textAttributes, for: UIControlState())
        UIApplication.shared.statusBarStyle = .lightContent
        
        UITabBarItem.appearance().setTitleTextAttributes(TextAttributes.textAttributes, for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes(TextAttributes.textAttributes, for: .normal)
        UITabBar.appearance().barTintColor = UIColor.backgroundColor()
        UITabBar.appearance().isTranslucent = false
        
        HNAppearance.setAppearances() // for appearances that weren't accessible from swift
    }

}

