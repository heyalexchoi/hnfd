//
//  ReadabilityArticle.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import SwiftyJSON

struct ReadabilityArticle: ResponseObjectSerializable, DataSerializable {
    
    let content: String
    let domain: String
    let author: String
    let URLString: String
    let shortURL: URL?
    let title : String
    let excerpt: String
    let wordCount: Int
    let totalPages: Int
    let dek: String
    let leadImageURL: URL?
    let datePublished: Date?
    
    var readingProgress: CGFloat
    
    var cacheKey: String {
        return type(of: self).cacheKeyForURLString(URLString)
    }
    
    let readabilityDateFormat = "yyyy-MM-dd HH:mm:ss"
    
    init(json: JSON) {
        content = json["content"].stringValue
        domain = json["domain"].stringValue
        author = json["author"].stringValue
        URLString = json["url"].stringValue
        shortURL = URL(string: json["short_url"].string ?? "")
        title = json["title"].stringValue
        excerpt = json["excerpt"].stringValue
        wordCount = json["word_count"].intValue
        totalPages = json["total_pages"].intValue
        dek = json["dek"].stringValue
        leadImageURL = URL(string: json["lead_image_url"].string ?? "")
        datePublished = DateFormatter.dateFromString(json["date_published"].stringValue, format: readabilityDateFormat)
        readingProgress = CGFloat(json["reading_progress"].floatValue)
    }
    
    var asJSON: Any {
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
    
    var asData: Data {
        if let data = try? JSONSerialization.data(withJSONObject: asJSON) {
            return data
        }
        debugPrint("Story failed to serialize to JSON: \(self)")
        return Data()
    }
    
    static func cacheKeyForURLString(_ urlString: String) -> String {
        return "cached_article_\(urlString)"
    }
    
    func save() {
        Cache.shared.setArticle(self)
    }
}

