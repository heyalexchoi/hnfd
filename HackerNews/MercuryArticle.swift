//
//  MercuryArticle.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import SwiftyJSON


struct MercuryArticle: ResponseObjectSerializable {
    
    let title : String
    let content: String
    let author: String
    let datePublished: Date?
    let leadImageURL: URL?
    let dek: String
    let URLString: String
    let domain: String
    let excerpt: String
    let wordCount: Int
    let totalPages: Int
    let renderedPages: Int

    var readingProgress: CGFloat
    
    /* 2016-12-26T05:00:00.000Z */
    let readabilityDateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
    init?(json: JSON) {
        guard let content = json["content"].string,
        let title = json["title"].string
            else { return nil }
            
        self.content = content
        self.title = title
        domain = json["domain"].stringValue
        author = json["author"].stringValue
        URLString = json["url"].stringValue        
        excerpt = json["excerpt"].stringValue
        wordCount = json["word_count"].intValue
        totalPages = json["total_pages"].intValue
        renderedPages = json["rendered_pages"].intValue
        dek = json["dek"].stringValue
        leadImageURL = URL(string: json["lead_image_url"].stringValue)
        datePublished = DateFormatter.dateFromString(json["date_published"].stringValue, format: readabilityDateFormat)
        readingProgress = CGFloat(json["reading_progress"].floatValue)
    }
    
    var asJSON: Any {
        return [
            "content": content,
            "domain": domain,
            "author": author,
            "url": URLString,
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
    
    func save() {
        Cache.shared.setArticle(self)
    }
}

// MARK: - CACHING
extension MercuryArticle {
    
    static func cacheKeyForURLString(_ urlString: String) -> String {
        return "cached_article_\(urlString)"
    }
    
    var cacheKey: String {
        return type(of: self).cacheKeyForURLString(URLString)
    }
}

extension MercuryArticle: DataSerializable {
    
    var asData: Data {
        if let data = try? JSONSerialization.data(withJSONObject: asJSON) {
            return data
        }
        debugPrint("Story failed to serialize to JSON: \(self)")
        return Data()
    }
}
