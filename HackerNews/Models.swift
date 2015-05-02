//
//  Model.swift
//  HackerNews
//
//  Created by alexchoi on 4/15/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import SwiftyJSON

struct Story {
    
    enum Type: String {
        case Job = "job",
        Story = "story",
        Poll = "poll",
        PollOpt = "pollopt"
    }
    
    let by: String
    let descendants: Int
    let id: Int
    let kids: [Int]
    let score: Int
    let text: String
    let time: Int
    let title: String
    let type: Type
    let URL: NSURL?
    let children: [Comment]
    let date: NSDate
    
    init(json: JSON) {
        self.by = json["by"].stringValue
        self.descendants = json["descendants"].intValue
        self.id = json["_id"].intValue
        self.kids = json["kids"].arrayValue.map { $0.intValue }
        self.score = json["score"].intValue
        self.text = json["text"].stringValue
        self.time = json["time"].intValue
        self.title = json["title"].stringValue
        self.type = Type(rawValue: json["type"].stringValue)!
        self.URL = json["url"].URL
        self.children = json["children"].arrayValue.map { Comment(json: $0, level: 1) } .filter { !$0.deleted }
        self.date = NSDate(timeIntervalSince1970: NSTimeInterval(self.time))
    }
}

struct Comment {
    
    let by: String
    let id: Int
    let kids: [Int]
    let parent: Int
    let text: String
    let time: Int
    let children: [Comment]
    let deleted: Bool
    let level: Int
    let date: NSDate
    
    init(json: JSON, level: Int) {
        self.by = json["by"].stringValue
        self.id = json["_id"].intValue
        self.parent = json["parent"].intValue
        self.kids = json["kids"].arrayValue.map { $0.intValue }
        self.time = json["time"].intValue
        self.text = json["text"].stringValue
        self.deleted = json["deleted"].boolValue
        self.children = json["children"].arrayValue.map { Comment(json: $0, level: level + 1) } .filter { !$0.deleted }
        self.level = level
        self.date = NSDate(timeIntervalSince1970: NSTimeInterval(self.time))
    }
}

struct ReadabilityArticle {
    
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
        self.content = json["content"].stringValue
        self.domain = json["domain"].stringValue
        self.author = json["author"].stringValue
        self.URL = json["url"].URL
        self.shortURL = json["short_url"].URL
        self.title = json["title"].stringValue
        self.excerpt = json["excerpt"].stringValue
        self.wordCount = json["word_count"].intValue
        self.totalPages = json["total_pages"].intValue
        self.dek = json["dek"].stringValue
        self.leadImageURL = json["lead_image_url"].URL
        self.attributedContent = NSAttributedString(htmlString: self.content)
    }
}
