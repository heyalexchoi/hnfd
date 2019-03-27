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
    
    static let textAttributes = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.textFont(), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.textColor()]
    static let detailAttributes = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.detailFont(), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.textColor()]
    static let textReaderAttributes = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.textReaderFont(), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.textColor()]
    static let titleAttributes = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.titleFont(), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.textColor()]
    static let largeTitleAttributes = [convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.largeTitleFont(), convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor.textColor()]
    static let centerAlignment: [String: AnyObject] = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return [convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): paragraphStyle]
    }()
    static func URLAttributes(_ URL: Foundation.URL) -> [String: AnyObject] {
        return [DTLinkAttribute: URL as AnyObject]
    }
    
    static func attributesWithFontAndColor(font: UIFont, color: UIColor) -> [String: Any] {
        return [
            convertFromNSAttributedStringKey(NSAttributedString.Key.font): font,
            convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): color
        ]
    }
}

struct Appearance {
    
    static func setAppearances() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(color: UIColor.backgroundColor()), for: .default)
        UINavigationBar.appearance().titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary(TextAttributes.titleAttributes)
        UINavigationBar.appearance().tintColor = UIColor.textColor()
        UIBarButtonItem.appearance().setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary(TextAttributes.textAttributes), for: UIControl.State())
        UIApplication.shared.statusBarStyle = .lightContent
        
        // tab bar unselected
        UITabBarItem.appearance().setTitleTextAttributes(
            convertToOptionalNSAttributedStringKeyDictionary(TextAttributes.attributesWithFontAndColor(font: .textFont(), color: UIColor.separatorColor())),
            for: .normal)
        // tab bar selected
        UITabBarItem.appearance().setTitleTextAttributes(
            convertToOptionalNSAttributedStringKeyDictionary(TextAttributes.attributesWithFontAndColor(font: .textFont(), color: UIColor.textColor())),
            for: .selected)

        UITabBar.appearance().barTintColor = UIColor.backgroundColor()
        UITabBar.appearance().isTranslucent = false
        
        HNAppearance.setAppearances() // for appearances that weren't accessible from swift
    }

}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
