//
//  Model.swift
//  HackerNews
//
//  Created by alexchoi on 4/15/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import SwiftyJSON

class StoryItem {
    let id: Int
    var story: Story?
    init(id: Int, story: Story?) {
        self.id = id
        self.story = story
    }
    init(json: JSON) {
        self.id = json.intValue
        self.story = nil
    }
}

struct Story {
    
    enum Type: String {
        case Job = "job",
        Story = "story",
        Comment = "comment",
        Poll = "poll",
        PollOpt = "pollopt"
    }
    
    let by: String
    let descendants: Int
    let id: Int
    let kids: [Int]
    let score: Int
    let time: Int
    let title: String
    let URL: NSURL
    let type: Type
    
    init(json: JSON) {
        self.by = json["by"].stringValue
        self.descendants = json["descendants"].intValue
        self.id = json["id"].intValue
        self.kids = json["kids"].arrayValue.map { $0.intValue }
        self.score = json["score"].intValue
        self.time = json["time"].intValue
        self.title = json["title"].stringValue
        self.URL = json["url"].URL ?? NSURL(string: "https://www.google.com")!
        self.type = Type(rawValue: json["type"].stringValue)!
    }
}

struct ReadabilityArticle {
    
    let content: String
    let domain: String
    let author: String
    let URL: NSURL
    let shortURL: NSURL
    let title : String
    let excerpt: String
    let wordCount: Int
    let totalPages: Int
    let dek: String
    let leadImageURL: NSURL
    
    init(json: JSON) {
        self.content = json["content"].stringValue
        self.domain = json["domain"].stringValue
        self.author = json["author"].stringValue
        self.URL = json["url"].URL ?? NSURL(string: "https://www.google.com")!
        self.shortURL = json["short_url"].URL ?? NSURL(string: "https://www.google.com")!
        self.title = json["title"].stringValue
        self.excerpt = json["excerpt"].stringValue
        self.wordCount = json["word_count"].intValue
        self.totalPages = json["total_pages"].intValue
        self.dek = json["dek"].stringValue
        self.leadImageURL = json["lead_image_url"].URL ?? NSURL(string: "https://www.google.com")!
    }
}

class CommentItem {
    
    let id: Int
    var comment: Comment?
    var kids = [CommentItem]()
    
    init(json: JSON) {
        self.id = json.intValue
        self.comment = nil
    }
    
    init(id: Int) {
        self.id = id
        self.comment = nil
    }
    
}

struct Comment {
    
    let by: String
    let id: Int
    let kids: [Int]
    let parent: Int
    let text: String
    let attributedText: NSAttributedString
    let time: Int
    
    init(json: JSON) {
        self.by = json["by"].stringValue
        self.id = json["id"].intValue
        self.parent = json["parent"].intValue
        self.kids = json["kids"].arrayValue.map { $0.intValue }
        self.time = json["time"].intValue
        self.text = json["text"].stringValue
        self.attributedText = NSAttributedString(htmlString: self.text)
    }
}
