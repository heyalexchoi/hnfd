//
//  ReadabilityArticle.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import DTCoreText
import SwiftyJSON

class ReadabilityArticle: NSObject, NSCoding {
    
    let content: String
    let domain: String
    let author: String
    let URL: NSURL?
    let shortURL: NSURL?
    let title : String
    let excerpt: String
    let wordCount: Int
    let totalPages: Int
    let dek: String
    let leadImageURL: NSURL?
    let attributedContent: NSAttributedString
    
    init(json: JSON) {
        content = json["content"].stringValue
        domain = json["domain"].stringValue
        author = json["author"].stringValue
        URL = json["url"].URL
        shortURL = json["short_url"].URL
        title = json["title"].stringValue
        excerpt = json["excerpt"].stringValue
        wordCount = json["word_count"].intValue
        totalPages = json["total_pages"].intValue
        dek = json["dek"].stringValue
        leadImageURL = json["lead_image_url"].URL
        let data = self.content.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let attributedContent = data.length > 0 ? NSMutableAttributedString(HTMLData: data, options: [DTDefaultFontName: UIFont.textReaderFont().fontName, DTDefaultFontSize: UIFont.textReaderFont().pointSize, DTDefaultTextColor: UIColor.textColor(), DTDefaultLinkColor: UIColor.tintColor()], documentAttributes: nil) : NSMutableAttributedString(string: "")
        attributedContent.enumerateAttribute(NSAttachmentAttributeName, inRange: NSRange(location: 0, length: attributedContent.length), options: nil) { (attribute, range, stop) -> Void in
            if let attachment = attribute as? DTImageTextAttachment {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .Center
                attributedContent.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: range)
            }
        }
        
        self.attributedContent = attributedContent.copy() as! NSAttributedString
    }
    
    func toJSON() -> AnyObject {
        return [
            "content": content,
            "domain": domain,
            "author": author,
            "url": URL?.absoluteString ?? "",
            "short_url": shortURL?.absoluteString ?? "",
            "title": title,
            "excerpt": excerpt,
            "word_count": wordCount,
            "totalPages": totalPages,
            "dek": dek,
            "lead_image_url": leadImageURL?.absoluteString ?? ""
        ]
    }
    
    required convenience init(coder decoder: NSCoder) {
        let json: AnyObject = decoder.decodeObjectForKey("json")!
        self.init(json:JSON(json))
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(toJSON(), forKey: "json")
    }
    
}

