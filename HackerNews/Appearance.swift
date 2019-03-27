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
    static let largeTitleAttributes = [NSFontAttributeName: UIFont.largeTitleFont(), NSForegroundColorAttributeName: UIColor.textColor()]
    static let centerAlignment: [String: AnyObject] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return [NSParagraphStyleAttributeName: paragraphStyle]
    }()
    static func URLAttributes(_ URL: Foundation.URL) -> [String: AnyObject] {
        return [DTLinkAttribute: URL as AnyObject]
    }
    
    static func attributesWithFontAndColor(font: UIFont, color: UIColor) -> [String: Any] {
        return [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color
        ]
    }
}

struct Appearance {
    
    static func setAppearances() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(color: UIColor.backgroundColor()), for: .default)
        UINavigationBar.appearance().titleTextAttributes = TextAttributes.titleAttributes
        UINavigationBar.appearance().tintColor = UIColor.textColor()
        UIBarButtonItem.appearance().setTitleTextAttributes(TextAttributes.textAttributes, for: UIControlState())
        UIApplication.shared.statusBarStyle = .lightContent
        
        // tab bar unselected
        UITabBarItem.appearance().setTitleTextAttributes(
            TextAttributes.attributesWithFontAndColor(font: .textFont(), color: UIColor.separatorColor()),
            for: .normal)
        // tab bar selected
        UITabBarItem.appearance().setTitleTextAttributes(
            TextAttributes.attributesWithFontAndColor(font: .textFont(), color: UIColor.textColor()),
            for: .selected)

        UITabBar.appearance().barTintColor = UIColor.backgroundColor()
        UITabBar.appearance().isTranslucent = false
        
        HNAppearance.setAppearances() // for appearances that weren't accessible from swift
    }

}

