//
//  Story.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import SwiftyJSON
import DTCoreText

extension StoriesType: Downloadable {
    var cacheKey: String {
        return rawValue
    }
}

extension Story: Downloadable {
    var cacheKey: String {
        return type(of: self).cacheKey(id)
    }
}

extension Sequence where Iterator.Element == Story {
    
    /*! Orders collection of stories by id according to the order of the given ids. computational complexity: 2*O(n) */
    func orderBy(ids: [Int]) -> [Story] {
        var mappedStories = [Int: Story]()
        for story in self {
            mappedStories[story.id] = story
        }
        var orderedStories = [Story]()
        for id in ids {
            if let story = mappedStories[id] {
                orderedStories.append(story)
            }
        }
        return orderedStories
    }
}

enum StoriesType: String {
    
    case Top = "topstories"
    case New = "newstories"
    case Show = "showstories"
    case Ask = "askstories"
    case Job = "jobstories"
    case Pinned = "pinnedstories"
    
    static var allValues = [Top, New, Show, Ask, Job, Pinned]
    
    var title: String {
        return rawValue.replacingOccurrences(of: "stories", with: "").capitalized
    }
    var isCached: Bool {
        return Cache.shared.hasFileCachedItemForKey(cacheKey)
    }
}

extension Story {
    static var pinnedIdsCacheKey = "pinnedStoryIds"
}

extension Int: ResponseObjectSerializable {
    init?(json: JSON) {
        guard let int = json.int else { return nil }
        self = int
    }
}

extension Int: JSONSerializable {
    var asJSON: Any {
        return self
    }
}

struct Story: ResponseObjectSerializable, DataSerializable, JSONSerializable {
    
    enum Kind: String {
        case Job = "job",
        Story = "story",
        Poll = "poll",
        PollOpt = "pollopt"
        func toJSON() -> AnyObject {
            return rawValue as AnyObject
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
    let kind: Kind
    let URL: Foundation.URL?
    let URLString: String? // the percent encoded URL is inappropriate for several use cases including sending to readability and a working href in a webview
    let children: [Comment]
    let date: Date
    let updated: String
    
    static func cacheKey(_ id: Int) -> String {
        return "cached_story_\(id)"
    }
    static func isCached(_ id: Int) -> Bool {
        return Cache.shared.hasFileCachedItemForKey(cacheKey(id))
    }
    var articleCacheKey: String? {
        guard let URLString = URLString else { return nil }
        return MercuryArticle.cacheKeyForURLString(URLString)
    }
    var isCached: Bool {
        return Cache.shared.hasFileCachedItemForKey(cacheKey)
    }
    var isArticleCached: Bool {
        return Cache.shared.hasFileCachedItemForKey(articleCacheKey)
    }
    
    init?(json: JSON) {
        guard let kind = Kind(rawValue: json["type"].stringValue)
            else { return nil }
        
        self.by = json["by"].stringValue
        self.descendants = json["descendants"].intValue
        self.id = json["_id"].intValue
        self.kids = json["kids"].arrayValue.map { $0.intValue }
        self.score = json["score"].intValue
        self.text = json["text"].stringValue
        // could probably make this a lazy var:
        let data = text.data(using: String.Encoding.utf8)!
        self.attributedText = data.count > 0 ? NSAttributedString(htmlData: data, options: [DTUseiOS6Attributes: true, DTDefaultFontName: UIFont.textReaderFont().fontName, DTDefaultFontSize: UIFont.textReaderFont().pointSize, DTDefaultTextColor: UIColor.textColor(), DTDefaultLinkColor: UIColor.tintColor()], documentAttributes: nil) : NSAttributedString(string: "")
        self.time = json["time"].intValue
        self.title = json["title"].stringValue
        self.kind = kind
        self.URLString = json["url"].string
        self.URL = Foundation.URL(string: json["url"].string ?? "")
        self.children = json["children"].arrayValue.map { Comment(json: $0, level: 1) } .filter { !$0.deleted }
        self.date = Date(timeIntervalSince1970: TimeInterval(self.time))
        self.updated = json["updated"].stringValue
    }
    
    var asJSON: Any {
        return [
            "by": by,
            "descendants": descendants,
            "_id": id,
            "kids": kids,
            "score": score,
            "text": text,
            "time": time,
            "title": title,
            "type": kind.toJSON(),
            "url": URL?.absoluteString ?? "",
            "children": children.map { $0.toJSON() }
        ]
    }
    
    var asData: Data {
        if let data = try? JSONSerialization.data(withJSONObject: asJSON) {
            return data
        }
        debugPrint("Story failed to serialize to JSON: \(self)")
        return Data()
    }
}

