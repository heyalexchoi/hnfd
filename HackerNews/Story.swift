//
//  Story.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//


import SwiftyJSON
import DTCoreText

enum StoriesType: String {
    case
    Top = "topstories",
    New = "newstories",
    Show = "showstories",
    Ask = "askstories",
    Job = "jobstories",
    Saved = "savedstories"
    static var allValues = [Top, New, Show, Ask, Job, Saved]
    var title: String {
        return rawValue.stringByReplacingOccurrencesOfString("stories", withString: " stories").capitalizedString
    }
    var cacheKey: String {
        return rawValue
    }
    var isCached: Bool {
        return Cache.sharedCache().hasFileCachedItemForKey(cacheKey)
    }
}

func ==(l: Story, r: Story) -> Bool {
    return l.id == r.id
}

extension Story { // HASHABLE
    override var hashValue: Int {
        return id.hashValue
    }
}

class Story: NSObject, NSCoding {
    
    enum Type: String {
        case Job = "job",
        Story = "story",
        Poll = "poll",
        PollOpt = "pollopt"
        func toJSON() -> AnyObject {
            return rawValue
        }
    }
    
    let by: String
    let descendants: Int
    let id: Int
    let kids: [Int]
    let score: Int
    let text: String
    let attributedText: NSAttributedString
    let time: Int
    let title: String
    let type: Type
    let URL: NSURL?
    let URLString: String? // the percent encoded URL is inappropriate for several use cases including sending to readability and a working href in a webview
    let children: [Comment]
    let date: NSDate
    let updated: String
    // want var to see if full story exists in cache
    // want var to track if user 'pinned' story
    var cacheKey: String {
        return self.dynamicType.cacheKey(id)
    }
    class func cacheKey(id: Int) -> String {
        return "cached_story_\(id)"
    }
    class func isCached(id: Int) -> Bool {
        return Cache.sharedCache().hasFileCachedItemForKey(cacheKey(id))
    }
    var articleCacheKey: String? {
        guard let URLString = URLString else { return nil }
        return ReadabilityArticle.cacheKeyForURLString(URLString)
    }
    var isCached: Bool {
        return Cache.sharedCache().hasFileCachedItemForKey(cacheKey)
    }
    var isArticleCached: Bool {
        return Cache.sharedCache().hasFileCachedItemForKey(articleCacheKey)
    }
    
    init(json: JSON) {
        self.by = json["by"].stringValue
        self.descendants = json["descendants"].intValue
        self.id = json["_id"].intValue
        self.kids = json["kids"].arrayValue.map { $0.intValue }
        self.score = json["score"].intValue
        self.text = json["text"].stringValue
        // could probably make this a lazy var:
        let data = text.dataUsingEncoding(NSUTF8StringEncoding)!
        self.attributedText = data.length > 0 ? NSAttributedString(HTMLData: data, options: [DTUseiOS6Attributes: true, DTDefaultFontName: UIFont.textReaderFont().fontName, DTDefaultFontSize: UIFont.textReaderFont().pointSize, DTDefaultTextColor: UIColor.textColor(), DTDefaultLinkColor: UIColor.tintColor()], documentAttributes: nil) : NSAttributedString(string: "")
        self.time = json["time"].intValue
        self.title = json["title"].stringValue
        self.type = Type(rawValue: json["type"].stringValue)!
        self.URLString = json["url"].string
        self.URL = json["url"].URL
        self.children = json["children"].arrayValue.map { Comment(json: $0, level: 1) } .filter { !$0.deleted }
        self.date = NSDate(timeIntervalSince1970: NSTimeInterval(self.time))
        self.updated = json["updated"].stringValue
    }
    
    func toJSON() -> AnyObject {
        return [
            "by": by,
            "descendants": descendants,
            "_id": id,
            "kids": kids,
            "score": score,
            "text": text,
            "time": time,
            "title": title,
            "type": type.toJSON(),
            "url": URL?.absoluteString ?? "",
            "children": children.map { $0.toJSON() }
        ]
    }
    
    required convenience init(coder decoder: NSCoder) {
        let json: AnyObject = decoder.decodeObjectForKey("json")!
        self.init(json:JSON(json))
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(toJSON(), forKey: "json")
    }
    
    override var hash: Int {
        return hashValue
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? Story {
            return id == object.id
        }
        return false
    }
    
}

