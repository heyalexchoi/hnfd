//
//  ReadabilityArticle.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import SwiftyJSON

class ReadabilityArticle: NSObject, NSCoding {
    
    let content: String
    let domain: String
    let author: String
    let URLString: String
    let shortURL: NSURL?
    let title : String
    let excerpt: String
    let wordCount: Int
    let totalPages: Int
    let dek: String
    let leadImageURL: NSURL?
    let datePublished: NSDate?
    
    var readingProgress: CGFloat
    
    var cacheKey: String {
        return self.dynamicType.cacheKeyForURLString(URLString)
    }
    
    let readabilityDateFormat = "yyyy-MM-dd HH:mm:ss"
    
    init(json: JSON) {
        content = json["content"].stringValue
        domain = json["domain"].stringValue
        author = json["author"].stringValue
        URLString = json["url"].stringValue
        shortURL = json["short_url"].URL
        title = json["title"].stringValue
        excerpt = json["excerpt"].stringValue
        wordCount = json["word_count"].intValue
        totalPages = json["total_pages"].intValue
        dek = json["dek"].stringValue
        leadImageURL = json["lead_image_url"].URL
        datePublished = DateFormatter.dateFromString(json["date_published"].stringValue, format: readabilityDateFormat)
        readingProgress = CGFloat(json["reading_progress"].floatValue)
    }
    
    func toJSON() -> AnyObject {
        return [
            "content": content,
            "domain": domain,
            "author": author,
            "url": URLString,
            "short_url": shortURL?.absoluteString ?? "",
            "title": title,
            "excerpt": excerpt,
            "word_count": wordCount,
            "totalPages": totalPages,
            "dek": dek,
            "lead_image_url": leadImageURL?.absoluteString ?? "",
            "date_published": datePublished != nil ? DateFormatter.stringFromDate(datePublished!, format: readabilityDateFormat) : "",
            "reading_progress": readingProgress
        ]
    }
    
    required convenience init(coder decoder: NSCoder) {
        let json: AnyObject = decoder.decodeObjectForKey("json")!
        self.init(json:JSON(json))
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(toJSON(), forKey: "json")
    }
    
    class func cacheKeyForURLString(urlString: String) -> String {
        return "cached_article_\(urlString)"
    }
    
    func save() {        
        Cache.sharedCache().setArticle(self, completion: nil)
    }
    
}

