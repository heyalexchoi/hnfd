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
    
    static let textAttributes = [NSAttributedString.Key.font: UIFont.textFont(), NSAttributedString.Key.foregroundColor: UIColor.textColor()]
    static let detailAttributes = [NSAttributedString.Key.font: UIFont.detailFont(), NSAttributedString.Key.foregroundColor: UIColor.textColor()]
    static let textReaderAttributes = [NSAttributedString.Key.font: UIFont.textReaderFont(), NSAttributedString.Key.foregroundColor: UIColor.textColor()]
    static let titleAttributes = [NSAttributedString.Key.font: UIFont.titleFont(), NSAttributedString.Key.foregroundColor: UIColor.textColor()]
    static let largeTitleAttributes = [NSAttributedString.Key.font: UIFont.largeTitleFont(), NSAttributedString.Key.foregroundColor: UIColor.textColor()]
    static let centerAlignment: [NSAttributedString.Key: AnyObject] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return [NSAttributedString.Key.paragraphStyle: paragraphStyle]
    }()
    static func URLAttributes(_ URL: Foundation.URL) -> [NSAttributedString.Key: AnyObject] {
        let convertedDTLinkAttribute = NSAttributedString.Key(DTLinkAttribute)
        return [convertedDTLinkAttribute: URL as AnyObject]
    }
    
    static func attributesWithFontAndColor(font: UIFont, color: UIColor) -> [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: color
        ]
    }
}

struct Appearance {
    
    static func setAppearances() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(color: UIColor.backgroundColor()), for: .default)
        UINavigationBar.appearance().titleTextAttributes = TextAttributes.titleAttributes
        UINavigationBar.appearance().tintColor = UIColor.textColor()
        UIBarButtonItem.appearance().setTitleTextAttributes(TextAttributes.textAttributes, for: UIControl.State())
        UIApplication.shared.statusBarStyle = .lightContent
        
        // tab bar unselected
        UITabBarItem.appearance().setTitleTextAttributes(
            TextAttributes.attributesWithFontAndColor(font: .textFont(), color: UIColor.hnSeparatorColor()),
            for: .normal)
        // tab bar selected
        UITabBarItem.appearance().setTitleTextAttributes(
           TextAttributes.attributesWithFontAndColor(font: .textFont(), color: .textColor()),
            for: .selected)

        UITabBar.appearance().barTintColor = UIColor.backgroundColor()
        UITabBar.appearance().isTranslucent = false
        
        HNAppearance.setAppearances() // for appearances that weren't accessible from swift
    }

}
