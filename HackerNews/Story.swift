//
//  Story.swift
//  HackerNews
//
//  Created by Alex Choi on 5/10/15.
//  Copyright (c) 2015 Alex Choi. All rights reserved.
//

import SwiftyJSON
import DTCoreText

extension StoriesType {
    
    func cacheKey(page: Int) -> String {
        return "stories?type=\(rawValue)&page=\(page)"
    }
    
}

extension Story {
    
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
    
    case News = "news"
    case Newest = "newest"
    case Show = "show"
    case Ask = "ask"
    case Job = "jobs"
    case Pinned = "pinned"
    
    static var allValues = [News, Newest, Show, Ask, Job, Pinned]
    
    var title: String {
        return rawValue.capitalized
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

struct JsonMapper {
    /**
     Transforms a JSON to another JSON.
     First, using the given mapping dictionary to map values from one key to another,
     eg: mapping dictionary ["object_id": "id"]
     will produce json with ["id": 1234] from json with ["object_id": 1234].
     Then, applying given additional transformations.
     */
    static func transform(
        json: JSON,
        mappingDict: [String: String],
        additional: (([String: Any]) -> [String: Any]))
        -> JSON? {
        guard let dictionary = json.dictionaryObject else {
            return nil
        }
        let newDict = DictionaryMapper.transform(dict: dictionary, mappingDict: mappingDict, additional: additional)
        return JSON(newDict)
    }
}

struct DictionaryMapper {
    
    /**
     Transforms a dictionary to another dictionary.
     First, using the given mapping dictionary to map values from one key to another,
     eg: mapping dictionary ["object_id": "id"]
     will produce dictionary with ["id": 1234] from dictionary with ["object_id": 1234].
     Then, applying given additional transformations.
     */
    static func transform(
        dict: [String: Any],
        mappingDict: [String: String],
        additional: (([String: Any]) -> [String: Any]))
        -> [String: Any] {
            var newDict = [String: Any]()
            for (key, value) in dict {
                guard let newKey = mappingDict[key] else {
                    continue
                }
                newDict[newKey] = value
            }
            return additional(newDict)
    }
}

struct HNAlgoliaSearchResponseWrapper: ResponseObjectSerializable {
    let stories: [Story]
    init?(json: JSON) {
        let hits = json["hits"].arrayValue
        stories = hits.map { HNAlgoliaSearchStory(json: $0)?.story }.compactMap { $0 }
    }
}

struct HNAlgoliaSearchStory: ResponseObjectSerializable {
    
    let story: Story
    
    init?(json: JSON) {
        let transformedJSONOptional = JsonMapper.transform(json: json, mappingDict: HNAlgoliaSearchStory.toStoryPropertyMap, additional: HNAlgoliaSearchStory.additionalMapping)
        guard let transformedJSON = transformedJSONOptional,
            let story = Story(json: transformedJSON) else {
            return nil
        }
        
        self.story = story
    }
}

extension HNAlgoliaSearchStory {

    static var toStoryPropertyMap: [String: String] {
        // maps property keys of algolia search api story objects
        // to those of the hnfd api story objects
        return [
            "author": "user",
            "num_comments": "comments_count",
            "objectID": "id",
            "points": "points",
            "created_at_i": "time",
            "title": "title",
            "url": "url"
        ]
    }
    
    static func additionalMapping(dict: [String: Any]) -> [String: Any] {
        var dict = dict
        // type property doesn't map well. have to scan tags. this could be improved but no need yet https://hn.algolia.com/api
        let tags = (dict["_tags"] as? [String]) ?? [String]()
        let mapsToLink = ["story", "show_hn"]
        let mapsToAsk = ["ask_hn", "poll", "pollopt"]
        
        if !Set(mapsToLink).intersection(tags).isEmpty {
            dict["type"] = "link"
        } else if !Set(mapsToAsk).intersection(tags).isEmpty {
            dict["type"] = "ask"
        } else {
            dict["type"] = "link" // 🤷🏽‍♀️
        }
        
        return dict
    }
    
}

struct Story: ResponseObjectSerializable, DataSerializable, JSONSerializable {
    
    enum Kind: String {
        case Job = "job",
        Link = "link",
        Ask = "ask"
        
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
        self.by = json["user"].stringValue
        self.descendants = json["comments_count"].intValue
        self.id = json["id"].intValue
        self.kids = json["kids"].arrayValue.map { $0.intValue } // don't think i use this anyway
        self.score = json["points"].intValue
        self.text = json["content"].stringValue
        // could probably make this a lazy var:
        let data = text.data(using: String.Encoding.utf8)!
        self.attributedText = data.count > 0 ? NSAttributedString(htmlData: data, options: [DTUseiOS6Attributes: true, DTDefaultFontName: UIFont.textReaderFont().fontName, DTDefaultFontSize: UIFont.textReaderFont().pointSize, DTDefaultTextColor: UIColor.textColor(), DTDefaultLinkColor: UIColor.tintColor()], documentAttributes: nil) : NSAttributedString(string: "")
        self.time = json["time"].intValue
        self.title = json["title"].stringValue
        self.kind = kind // rethink this one. important, even?

        if let urlString = json["url"].string,
            let url = Foundation.URL(string: urlString),
             urlString.isValidURL {
            self.URLString = urlString
            self.URL = url
        } else {
            self.URLString = nil
            self.URL = nil
        }

        self.children = json["comments"].arrayValue.map { Comment(json: $0, level: 1) } .filter { !$0.deleted }
        self.date = Date(timeIntervalSince1970: TimeInterval(self.time))
        self.updated = json["updated"].stringValue // don't think i use this
    }

    var asJSON: Any {
        return [
            "user": by,
            "comments_count": descendants,
            "id": id,
            "kids": kids,
            "points": score,
            "content": text,
            "time": time,
            "title": title,
            "type": kind.toJSON(),
            "url": URL?.absoluteString ?? "",
            "comments": children.map { $0.toJSON() }
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

